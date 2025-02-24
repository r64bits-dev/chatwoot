class Api::V1::Accounts::ContactsController < Api::V1::Accounts::BaseController
  include Sift
  sort_on :email, type: :string
  sort_on :name, internal_name: :order_on_name, type: :scope, scope_params: [:direction]
  sort_on :phone_number, type: :string
  sort_on :last_activity_at, internal_name: :order_on_last_activity_at, type: :scope, scope_params: [:direction]
  sort_on :created_at, internal_name: :order_on_created_at, type: :scope, scope_params: [:direction]
  sort_on :company, internal_name: :order_on_company_name, type: :scope, scope_params: [:direction]
  sort_on :city, internal_name: :order_on_city, type: :scope, scope_params: [:direction]
  sort_on :country, internal_name: :order_on_country_name, type: :scope, scope_params: [:direction]

  RESULTS_PER_PAGE = 15

  before_action :check_authorization
  before_action :set_current_page, only: [:index, :active, :search, :filter]
  before_action :fetch_contact, only: [:show, :update, :destroy, :avatar, :contactable_inboxes, :destroy_custom_attributes]
  before_action :fetch_ticket, only: [:show]
  before_action :set_include_contact_inboxes, only: [:index, :search, :filter]

  def index
    @contacts_count = resolved_contacts.count
    @contacts = fetch_contacts(resolved_contacts)
  end

  def search
    render json: { error: 'Specify search string with parameter q' }, status: :unprocessable_entity if params[:q].blank? && return

    contacts = resolved_contacts.where(
      'name ILIKE :search OR email ILIKE :search OR phone_number ILIKE :search OR contacts.identifier LIKE :search
        OR contacts.additional_attributes->>\'company_name\' ILIKE :search',
      search: "%#{params[:q].strip}%"
    )
    @contacts_count = contacts.count
    @contacts = fetch_contacts(contacts)
  end

  def import
    render json: { error: I18n.t('errors.contacts.import.failed') }, status: :unprocessable_entity and return if params[:import_file].blank?

    ActiveRecord::Base.transaction do
      import = Current.account.data_imports.create!(data_type: 'contacts')
      import.import_file.attach(params[:import_file])
    end

    head :ok
  end

  def export
    column_names = params['column_names']
    Account::ContactsExportJob.perform_later(Current.account.id, column_names)
    head :ok, message: I18n.t('errors.contacts.export.success')
  end

  # returns online contacts
  def active
    contacts = Current.account.contacts.where(id: ::OnlineStatusTracker
                  .get_available_contact_ids(Current.account.id))
    @contacts_count = contacts.count
    @contacts = contacts.page(@current_page)
  end

  def show; end

  def filter
    result = ::Contacts::FilterService.new(params.permit!, current_user).perform
    contacts = result[:contacts]
    @contacts_count = result[:count]
    @contacts = fetch_contacts(contacts)
  end

  def contactable_inboxes
    @all_contactable_inboxes = Contacts::ContactableInboxesService.new(contact: @contact).get
    @contactable_inboxes = @all_contactable_inboxes.select { |contactable_inbox| policy(contactable_inbox[:inbox]).show? }
  end

  # TODO : refactor this method into dedicated contacts/custom_attributes controller class and routes
  def destroy_custom_attributes
    @contact.custom_attributes = @contact.custom_attributes.excluding(params[:custom_attributes])
    @contact.save!
  end

  def create
    ActiveRecord::Base.transaction do
      @contact = Current.account.contacts.new(permitted_params.except(:avatar_url))
      @contact.save!
      @contact_inbox = build_contact_inbox
      process_avatar_from_url
    end
  end

  def contact_and_message
    ActiveRecord::Base.transaction do
      #find_or_create_contact
      find_or_reuse_contact
      create_conversation_and_message
    end
  end

  def update
    @contact.assign_attributes(contact_update_params)
    @contact.save!
    process_avatar_from_url
  end

  def destroy
    if ::OnlineStatusTracker.get_presence(
      @contact.account.id, 'Contact', @contact.id
    )
      return render_error({ message: I18n.t('contacts.online.delete', contact_name: @contact.name.capitalize) },
                          :unprocessable_entity)
    end

    @contact.destroy!
    head :ok
  end

  def avatar
    @contact.avatar.purge if @contact.avatar.attached?
    @contact
  end

  private

  def find_or_create_contact
    @contact = current_account.contacts.find_or_create_by(
      name: permitted_params_message[:contact][:name],
      phone_number: only_numbers(permitted_params_message[:contact][:phone])
    )
    @contact.email = permitted_params_message[:contact][:email]
    @contact.save!
    @contact_inbox = build_contact_inbox
  end

  def find_or_reuse_contact
    phone_number = only_numbers(permitted_params_message[:contact][:phone])
    email = permitted_params_message[:contact][:email]
    name = permitted_params_message[:contact][:name]

    # Busca contato existente por telefone ou e-mail
    @contact = current_account.contacts.find_by(phone_number: phone_number) ||
               current_account.contacts.find_by(email: email)

    # Se não encontrar, cria um novo contato
    unless @contact
      @contact = current_account.contacts.create!(
        name: name,
        phone_number: phone_number,
        email: email
      )
    end

    # Garante que o contact_inbox seja criado ou reutilizado
    @contact_inbox = build_contact_inbox
  end

  def create_conversation_and_message
    Rails.logger.info "Permitted params: #{permitted_params_message.inspect}"
    Rails.logger.info "teamId from params: #{permitted_params[:teamId]}"
    Rails.logger.info "Contato reutilizado ou criado: #{@contact.inspect}"
  
    params_message = permitted_params_message
    if @contact_inbox.inbox.telegram?
      params_message[:additional_attributes] = {
        chat_id: find_chat_id
      }
    end
  
    # Primeiro, define o team_id com base no teamId enviado, se presente
    if permitted_params[:teamId].present?
      params_message[:team_id] = permitted_params[:teamId]
    end
  
    # Depois, aplica assign_current_user apenas se team_id ainda não foi definido
    if permitted_params[:assign_current_user] && !params_message[:team_id].present?
      params_message[:team_id] = current_user.teams.where(account: current_account).first&.id
      params_message[:assignee_id] = current_user.id
    elsif permitted_params[:assign_current_user]
      # Se assign_current_user é true e já temos um team_id, apenas seta o assignee
      params_message[:assignee_id] = current_user.id
    end
  
    params_message[:team_id] = permitted_params[:teamId] if permitted_params[:teamId].present?
  
    @conversation = ConversationBuilder.new(
      params: params_message,
      contact_inbox: @contact_inbox
    ).perform
  
    @message = Messages::MessageBuilder.new(
      current_user,
      @conversation,
      content: permitted_params_message[:message][:content]
    ).perform
  end

  # TODO: Move this to a finder class
  def resolved_contacts
    return @resolved_contacts if @resolved_contacts

    @resolved_contacts = Current.account.contacts.resolved_contacts

    @resolved_contacts = @resolved_contacts.tagged_with(params[:labels], any: true) if params[:labels].present?
    @resolved_contacts
  end

  def set_current_page
    @current_page = params[:page] || 1
  end

  def fetch_contacts(contacts)
    contacts_with_avatar = filtrate(contacts)
                           .includes([{ avatar_attachment: [:blob] }])
                           .page(@current_page).per(RESULTS_PER_PAGE)

    return contacts_with_avatar.includes([{ contact_inboxes: [:inbox] }]) if @include_contact_inboxes

    contacts_with_avatar
  end

  def build_contact_inbox
    return if params[:inbox_id].blank?

    inbox = Current.account.inboxes.find(params[:inbox_id])
    ContactInboxBuilder.new(
      contact: @contact,
      inbox: inbox,
      source_id: params[:source_id]
    ).perform
  end

  def permitted_params
    params.permit(:name, :identifier, :email, :phone_number, :avatar, :avatar_url, :assign_current_user, :teamId, additional_attributes: {},
                                                                                                         custom_attributes: {})
  end

  def permitted_params_message
    params.permit(:inbox_id, :contact_id, :type, :assign_current_user, :teamId, contact: {}, message: {})
  end

  def contact_custom_attributes
    return @contact.custom_attributes.merge(permitted_params[:custom_attributes]) if permitted_params[:custom_attributes]

    @contact.custom_attributes
  end

  def contact_update_params
    # we want the merged custom attributes not the original one
    permitted_params.except(:custom_attributes, :avatar_url).merge({ custom_attributes: contact_custom_attributes })
  end

  def set_include_contact_inboxes
    @include_contact_inboxes = if params[:include_contact_inboxes].present?
                                 params[:include_contact_inboxes] == 'true'
                               else
                                 true
                               end
  end

  def fetch_contact
    @contact = Current.account.contacts.includes(contact_inboxes: [:inbox]).find(params[:id])
  end

  def fetch_ticket
    return if params[:conversation_id].blank?

    @conversation = Current.account.conversations.find_by(display_id: params[:conversation_id])
    return if @conversation

    @conversation = Current.account.conversations.find_by(id: params[:conversation_id])
  end

  def process_avatar_from_url
    ::Avatar::AvatarFromUrlJob.perform_later(@contact, params[:avatar_url]) if params[:avatar_url].present?
  end

  def render_error(error, error_status)
    render json: error, status: error_status
  end

  def only_numbers(string)
    "+#{string.gsub(/[^\d]/, '')}"
  end

  def find_chat_id
    @contact_inbox.inbox.channel.find_chat_id
  end
end

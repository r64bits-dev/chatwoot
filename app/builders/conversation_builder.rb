class ConversationBuilder
  pattr_initialize [:params!, :contact_inbox!]

  def perform
    conversation = nil
    ActiveRecord::Base.transaction do
      @contact_inbox.with_lock do
        existing_conversation = look_up_existing_conversation
        conversation = existing_conversation || ::Conversation.create!(conversation_params)
      end
    end
    conversation
  end

  private

  def look_up_existing_conversation
    return if params[:type] == 'create_new_conversation'

    return unless @contact_inbox.inbox.lock_to_single_conversation?

    @contact_inbox.conversations.where(status: 'open').last
  end

  def create_new_conversation
    ::Conversation.create!(conversation_params)
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.warn("Duplicate conversation creation detected for contact_inbox_id: #{@contact_inbox.id}")

    look_up_existing_conversation
  end

  def conversation_params
    additional_attributes = params[:additional_attributes]&.permit! || {}
    custom_attributes = params[:custom_attributes]&.permit! || {}
    status = params[:status].present? ? { status: params[:status] } : {}

    # TODO: temporary fallback for the old bot status in conversation, we will remove after couple of releases
    # commenting this out to see if there are any errors, if not we can remove this in subsequent releases
    # status = { status: 'pending' } if status[:status] == 'bot'
    {
      account_id: @contact_inbox.inbox.account_id,
      inbox_id: @contact_inbox.inbox_id,
      contact_id: @contact_inbox.contact_id,
      contact_inbox_id: @contact_inbox.id,
      additional_attributes: additional_attributes,
      custom_attributes: custom_attributes,
      snoozed_until: params[:snoozed_until],
      assignee_id: params[:assignee_id],
      team_id: params[:team_id]
    }.merge(status)
  end
end

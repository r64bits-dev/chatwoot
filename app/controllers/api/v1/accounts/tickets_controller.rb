class Api::V1::Accounts::TicketsController < Api::V1::Accounts::BaseController
  include Api::V2::Tickets::TicketHelper

  before_action :fetch_ticket, only: %i[show update destroy assign resolve add_label remove_label]
  before_action :fetch_conversation, only: [:conversations]

  before_action :check_authorization

  RESULTS_PER_PAGE = 10

  def index
    @all_tickets = find_tickets
    @tickets = @all_tickets
               .search_by_params(params[:search])
               .search_by_status(params[:status])
               .order(created_at: :desc)
               .page(params[:page] || 1)
               .per(params[:per_page] || RESULTS_PER_PAGE)
  end

  def conversations
    @tickets = @conversation.tickets.limit(10)
  end

  def show
    if @ticket.nil?
      head :not_found
    else
      render json: @ticket, include: ['assignee', 'labels']
    end
  end

  def create
    Rails.logger.info "Parâmetros recebidos: #{params.inspect}"
    @ticket = build_ticket
    Rails.logger.info "Ticket criado: #{@ticket.inspect}, conversation_id: #{@ticket.conversation_id}"
  
    if @ticket&.persisted?
      send_ticket_notification if @ticket.send_notification?
      render json: @ticket, status: :created
    else
      Rails.logger.error "Erro ao salvar o ticket: #{@ticket.errors.full_messages}"
      render json: { error: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    update_ticket(@ticket)
    render json: @ticket, status: :ok
  end

  def destroy
    @ticket.destroy!
    head :ok
  end

  def labels
    @labels = current_account.labels.with_usage_count(:label_tickets)
  end

  def assign
    @ticket.assignee = User.find(params[:user_id]) || current_user
    @ticket.save!
  end

  def resolve
    raise CustomExceptions::Ticket, I18n.t('activerecord.errors.models.ticket.errors.already_resolved') if @ticket.resolved?
    raise CustomExceptions::Ticket, I18n.t('activerecord.errors.models.ticket.errors.need_to_be_assigned') if @ticket.assignee.blank?

    @ticket.update!(status: :resolved, resolved_at: Time.current)
    send_resolution_notification if @ticket.send_notification?
    render json: @ticket, status: :ok
  end

  def add_label
    @ticket.labels << Label.find(params[:label_id])
  end

  def remove_label
    @ticket.labels.delete(Label.find(params[:label_id]))
  end

  def export
    @tickets = current_account.tickets.order(created_at: :desc)
    send_data @tickets.to_csv, filename: 'tickets.csv', type: 'text/csv'
  end

  private

  def fetch_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def fetch_ticket
    @ticket = current_account.tickets.find(params[:id])
  end

  def find_tickets
    if current_user.administrator?
      current_account.tickets
    else
      current_account.tickets.assigned_to(current_user.id)
    end
  end

  def send_ticket_notification
    Rails.logger.info "Starting send_ticket_notification for ticket #{@ticket.id}"
    unless @ticket.conversation_id.present?
      Rails.logger.warn "No conversation_id for ticket #{@ticket.id}"
      return
    end
  
    conversation = Conversation.find(@ticket.conversation_id)
    Rails.logger.info "Conversation loaded: ID=#{conversation.id}, Account_ID=#{conversation.account_id}"
    unless conversation.present? && conversation.account_id == current_account.id
      Rails.logger.error "Conversation #{@ticket.conversation_id} não pertence ao account #{current_account.id}"
      return
    end
  
    message_content = "Seu ticket #{@ticket.id} foi criado com sucesso!, \nDescrição: #{@ticket.description}"
    message_builder = Messages::MessageBuilder.new(
      current_user,
      conversation,
      { content: message_content, account_id: current_account.id } # Forçar account_id
    )
    result = message_builder.perform
    if result
      Rails.logger.info "Notification sent for ticket #{@ticket.id}: #{message_content}"
    else
      Rails.logger.error "MessageBuilder failed silently for ticket #{@ticket.id}"
    end
  rescue StandardError => e
    Rails.logger.error "Failed to send notification for ticket #{@ticket.id}: #{e.message}"
  end

  def send_resolution_notification
    return unless @ticket.conversation_id.present?
  
    conversation = Conversation.find(@ticket.conversation_id)
    return unless conversation.present?
  
    resolved_at_formatted = @ticket.resolved_at.in_time_zone('America/Sao_Paulo').strftime('%d/%m/%Y %H:%M:%S')
    message_content = "Seu ticket foi resolvido! Número: #{@ticket.id}, Resolvido em: #{resolved_at_formatted}"
    
    message_builder = Messages::MessageBuilder.new(
      current_user,
      conversation,
      { content: message_content }
    )
    message_builder.perform
    
    Rails.logger.error "Notificação de resolução enviada para o ticket #{@ticket.id}: #{message_content}"
  rescue StandardError => e
    Rails.logger.error "Falha ao enviar notificação de resolução para o ticket #{@ticket.id}: #{e.message}"
  end
end
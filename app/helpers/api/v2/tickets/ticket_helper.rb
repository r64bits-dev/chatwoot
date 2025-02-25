module Api::V2::Tickets::TicketHelper
  def build_ticket
    ActiveRecord::Base.transaction do
      ticket = Ticket.new(ticket_params_with_agent)
      ticket.user = current_user # Garante que o user seja definido (obrigatório)
      ticket.conversation = find_conversation(params[:display_id]) if params[:display_id].present?
      ticket.account = current_account

      create_or_update_labels(ticket)
      ticket.save!
      ticket
    end
  end

  def update_ticket(ticket)
    ActiveRecord::Base.transaction do
      create_or_update_labels(ticket)
      ticket.update!(ticket_params)
      ticket
    end
  end

  def find_labels(labels)
    return [] if labels.blank?

    labels.map { |label| current_account.labels.find_id_or_title(label[:id] || label[:title]) }.flatten
  end

  def create_or_update_labels(ticket)
    ticket.labels << find_labels(params.dig(:ticket, :labels)) if params.dig(:ticket, :labels)
  rescue ActiveRecord::RecordNotUnique
    raise CustomExceptions::Ticket, I18n.t('activerecord.errors.models.ticket.errors.already_label_assigned')
  end

  def ticket_params
    # Permitir parâmetros no nível raiz e dentro de ticket
    request_params = params.permit(
      :title,
      :description,
      :status,
      :assigned_to,
      :conversation_id,
      :account_id,
      :user_id,
      :resolved_at,
      :send_notification,
      :agent_id, # Permitir agent_id no nível raiz
      ticket: [:title, :description, :status, :assigned_to, :conversation_id, :account_id, :user_id, :resolved_at, :send_notification, custom_attributes: {}]
    )

    # Usar ticket como base se existir, senão usar parâmetros raiz
    ticket_data = request_params[:ticket] || request_params
    ticket_data[:conversation_id] = params[:conversation_id] if params[:conversation_id].present?
    ticket_data
  end

  def ticket_params_with_agent
    # Pegar os parâmetros básicos
    base_params = ticket_params

    # Mapear agent_id para assigned_to se presente
    if params[:agent_id].present?
      base_params[:assigned_to] = params[:agent_id]
    end

    # Garantir que send_notification seja incluído
    base_params[:send_notification] = params[:sendNotification] if params[:sendNotification].present?
    
    base_params.except(:agent_id) # Remover agent_id para evitar conflitos
  end

  private

  def find_conversation(display_id)
    Conversation.find_by(display_id: display_id)
  end
end
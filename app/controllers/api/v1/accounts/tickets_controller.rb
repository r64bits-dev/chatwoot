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
    head :not_found if @ticket.nil?
  end

  def create
    @ticket = build_ticket
  end

  def update
    update_ticket(@ticket)
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
end

class V2::ReportTicketsBuilder
  include DateRangeHelper

  attr_reader :account, :params, :group_by

  DEFAULT_GROUP_BY = 'day'.freeze

  def initialize(account, params)
    @account = account
    @params = params
    @group_by = params[:group_by] || DEFAULT_GROUP_BY
  end

  def tickets_metrics
    users = load_users
    tickets = load_tickets
    resolved_tickets = tickets.resolved
    unresolved_tickets = tickets.unresolved

    users.map { |user| build_user_ticket_metrics(user, tickets, resolved_tickets, unresolved_tickets) }
  end

  private

  def load_users
    account.users.includes(:avatar_attachment, :account_users)
  end

  def load_tickets
    return account.tickets unless params[:since].present? && params[:until].present?

    account.tickets.where(created_at: range)
  end

  def build_user_ticket_metrics(user, tickets, resolved_tickets, unresolved_tickets)
    assigned_tickets = tickets.where(assigned_to: user.id)

    {
      id: user.id,
      name: user.name,
      email: user.email,
      thumbnail: user.avatar_url,
      availability: user.availability_status,
      tickets: assigned_tickets.count,
      resolved: resolved_tickets.where(assigned_to: user.id).count,
      unresolved: unresolved_tickets.where(assigned_to: user.id).count,
      avg_time_to_resolution_in_seconds: avg_time_to_resolution(assigned_tickets)
    }
  end

  def avg_time_to_resolution(tickets)
    return 0 if tickets.blank?

    total_time = tickets.sum { |ticket| ticket.resolution_time || 0 }
    total_time / tickets.size if total_time.positive?
  end
end

class V2::ReportInvoicesUsageBuilder < V2::ReportBuilderBase
  STATUSES = {
    incoming: 0,
    outgoing: 1
  }.freeze

  def build
    start_date, end_date = calculate_date_range
    end_date = adjust_end_date(end_date)

    sent_messages_count = count_messages(start_date, end_date, 'incoming')
    received_messages_count = count_messages(start_date, end_date, 'outgoing')
    messages = messages(start_date, end_date)

    {
      values: messages,
      extra_sent_messages: sent_messages_by_date(start_date, end_date),
      extra_received_messages: received_messages_by_date(start_date, end_date),
      summary: {
        total: messages.count,
        sent_messages: sent_messages_count,
        received_messages: received_messages_count
      }
    }
  end

  private

  def sent_messages_by_date(start_date, end_date)
    accounts.flat_map do |account|
      account.reporting_events
             .extra_messages_outgoing
             .where(created_at: start_date..end_date)
             .group_by { |event| event.created_at.to_date }
             .map { |date, events| { date: date, count: events.count } }
    end
  end

  def received_messages_by_date(start_date, end_date)
    accounts.flat_map do |account|
      account.reporting_events
             .extra_messages_incoming
             .where(created_at: start_date..end_date)
             .group_by { |event| event.created_at.to_date }
             .map { |date, events| { date: date, count: events.count } }
    end
  end

  def messages(start_date, end_date)
    accounts.flat_map do |account|
      account.messages
             .where(created_at: start_date..end_date, message_type: STATUSES.values)
             .select('DATE(messages.created_at) as date', :message_type, :id)
             .group_by { |message| message[:date] }
             .map { |date, messages| { date: date, count: messages.count } }
    end
  end

  def count_messages(start_date, end_date, message_type)
    accounts.sum do |account|
      account.messages
             .where(created_at: start_date..end_date, message_type: message_type_filter(message_type))
             .count
    end
  end

  def message_type_filter(type)
    STATUSES[type.to_sym]
  end
end

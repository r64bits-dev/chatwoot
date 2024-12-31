class V2::ReportInvoicesBuilder < V2::ReportBuilderBase
  def initialize(accounts, params)
    @total_invoices = 0
    @average_invoice_price = 0
    super
  end

  def invoices_metrics_admin
    start_date, end_date = calculate_date_range
    end_date = adjust_end_date(end_date)
    total_conversations, total_agents = calculate_totals(start_date, end_date)

    {
      values: values(start_date, end_date),
      summary: build_summary(total_conversations, total_agents)
    }
  rescue StandardError => e
    Rails.logger.error e.message
    default_summary
  end

  def invoices_metrics
    start_date, end_date = calculate_date_range
    end_date = adjust_end_date(end_date)
    {
      values: values(start_date, end_date),
      summary: {
        total: @total,
        total_invoices: @total_invoices,
        average_invoice_price: @average_invoice_price
      }
    }
  end

  private

  def values(start_date, end_date)
    if accounts.size > 1
      accounts.each_with_object({}) do |account, result|
        result[account.name] = months_in_range(start_date, end_date).map do |date|
          calculate_summary_for_period(account, date)
        end
      end
    else
      months_in_range(start_date, end_date).map do |date|
        calculate_summary_for_period(accounts.first, date)
      end
    end
  end

  def calculate_summary_for_period(account, date)
    periods = V2::BillingPeriod.new(group_by, date)
    extra_conversation_cost = sum_reporting_events_extra_conversations(account, periods.period_start, periods.period_end)
    extra_agent_cost = sum_reporting_events_extra_agents(account, periods.period_start, periods.period_end)
    total = calculate_total_price(account, extra_conversation_cost, extra_agent_cost)
    total_messages_sent = count_extra_messages_sent(account, periods.period_start, periods.period_end)
    total_messages_received = count_extra_messages_received(account, periods.period_start, periods.period_end)
    @total += total
    @total_invoices += 1

    @average_invoice_price = @total / @total_invoices

    build_metrics_data(account, periods, {
                         extra_conversation_cost: extra_conversation_cost,
                         extra_agent_cost: extra_agent_cost,
                         total: total,
                         total_messages_sent: total_messages_sent,
                         total_messages_received: total_messages_received
                       })
  end

  def sum_reporting_events_extra_agents(account, start_date, end_date)
    account.reporting_events
           .extra_agents
           .where(created_at: start_date..end_date)
           .sum(:value)
  end

  def sum_reporting_events_extra_conversations(account, start_date, end_date)
    account.reporting_events
           .extra_inboxes
           .where(created_at: start_date..end_date)
           .sum(:value)
  end

  def count_extra_messages_sent(account, start_date, end_date)
    account.reporting_events
           .extra_messages_outgoing
           .where(created_at: start_date..end_date)
           .count
  end

  def count_extra_messages_received(account, start_date, end_date)
    account.reporting_events
           .extra_messages_incoming
           .where(created_at: start_date..end_date)
           .count
  end

  def count_conversations(account, start_date, end_date)
    account.conversations.where(created_at: start_date..end_date).count
  end

  def count_agents(account, start_date, end_date)
    account.agents.where(created_at: start_date..end_date).count
  end

  def calculate_total_price(account, extra_conversation_cost, extra_agent_cost)
    account.account_plan&.product&.price.to_f + extra_conversation_cost + extra_agent_cost
  rescue StandardError
    0.0
  end

  def build_metrics_data(account, periods, metrics)
    {
      date: periods.period_start.to_time,
      total_conversations: count_conversations(account, periods.period_start, periods.period_end),
      total_agents: count_agents(account, periods.period_start, periods.period_end),
      base_price: account.account_plan&.product&.price.to_f,
      extra_conversation_cost: metrics[:extra_conversation_cost],
      extra_agent_cost: metrics[:extra_agent_cost],
      total_price: metrics[:total],
      extra_conversation_messages: metrics[:total_messages_sent],
      extra_agent_messages: metrics[:total_messages_received]
    }
  end

  def calculate_totals(start_date, end_date)
    total_conversations = 0
    total_agents = 0

    accounts.each do |account|
      total_conversations += count_conversations(account, start_date, end_date)
      total_agents += count_agents(account, start_date, end_date)
    end

    [total_conversations, total_agents]
  end

  def build_summary(total_conversations, total_agents)
    {
      total: @total,
      total_invoices: @total_invoices,
      average_invoice_price: @average_invoice_price,
      total_conversations: total_conversations,
      total_agents: total_agents
    }
  end

  def default_summary
    {
      values: [],
      summary: {
        total: 0,
        total_invoices: 0,
        average_invoice_price: 0,
        total_conversations: 0,
        total_agents: 0
      }
    }
  end
end

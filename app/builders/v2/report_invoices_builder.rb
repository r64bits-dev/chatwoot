class V2::ReportInvoicesBuilder
  include DateRangeHelper

  attr_reader :accounts, :params, :group_by, :date_range

  DEFAULT_GROUP_BY = 'month'.freeze
  DEFAULT_MONTHS_BEFORE = 3

  def initialize(accounts, params)
    @accounts = Array(accounts)
    @params = params
    @group_by = params[:group_by] || DEFAULT_GROUP_BY
    @date_range = range
    @total = 0
    @total_invoices = 0
    @average_invoice_price = 0
  end

  def invoices_metrics_admin
    start_date, end_date = calculate_date_range
    end_date = adjust_end_date(end_date)

    total_conversations = 0
    total_agents = 0

    accounts.each do |account|
      total_conversations += count_conversations(account, start_date, end_date)
      total_agents += count_agents(account, start_date, end_date)
    end

    {
      values: values(start_date, end_date),
      summary: {
        total: @total,
        total_invoices: @total_invoices,
        average_invoice_price: @average_invoice_price,
        total_conversations: total_conversations,
        total_agents: total_agents
      }
    }
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

  def calculate_date_range
    start_date = date_range&.first&.to_date || default_start_date
    end_date = date_range&.last&.to_date || default_end_date
    [start_date, end_date]
  end

  def adjust_end_date(end_date)
    end_date.day == 1 ? (end_date - 1.day).end_of_month : end_date.end_of_month
  end

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
    @total += total
    @total_invoices += 1

    @average_invoice_price = @total / @total_invoices

    build_metrics_data(account, periods, extra_conversation_cost, extra_agent_cost, total)
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

  def count_conversations(account, start_date, end_date)
    account.conversations.where(created_at: start_date..end_date).count
  end

  def count_agents(account, start_date, end_date)
    account.agents.where(created_at: start_date..end_date).count
  end

  def calculate_total_price(account, extra_conversation_cost, extra_agent_cost)
    account.account_plan.product.price.to_f + extra_conversation_cost + extra_agent_cost
  end

  def build_metrics_data(account, periods, extra_conversation_cost, extra_agent_cost, total)
    {
      date: periods.period_start.to_time,
      total_conversations: count_conversations(account, periods.period_start, periods.period_end),
      total_agents: count_agents(account, periods.period_start, periods.period_end),
      base_price: account.account_plan.product.price.to_f,
      extra_conversation_cost: extra_conversation_cost,
      extra_agent_cost: extra_agent_cost,
      total_price: total
    }
  end

  def default_start_date
    accounts.minimum(:created_at).beginning_of_day
  end

  def default_end_date
    Time.current.end_of_month
  end
end

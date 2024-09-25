class V2::ReportInvoicesBuilder
  include DateRangeHelper

  attr_reader :account, :params, :product, :account_plan, :date_range, :group_by

  DEFAULT_GROUP_BY = 'month'.freeze

  def initialize(account, params)
    @account = account
    @account_plan = account.account_plan
    raise 'Account plan not found' unless @account_plan

    @product = account_plan.product
    @params = params
    @group_by = params[:group_by] || DEFAULT_GROUP_BY
    @date_range = range
    @total = 0
  end

  def invoices_metrics
    start_date = date_range&.first&.to_date || default_start_date
    end_date = date_range&.last&.to_date || default_end_date

    {
      values: values(start_date, end_date),
      summary: {
        total: @total
      }
    }
  end

  private

  def sum_reporting_events_extra_agents(start_date, end_date)
    account.reporting_events
           .extra_agents
           .where(created_at: start_date..end_date)
           .sum(:value)
  end

  def sum_reporting_events_extra_conversations(start_date, end_date)
    account.reporting_events
           .extra_inboxes
           .where(created_at: start_date..end_date)
           .sum(:value)
  end

  def count_conversations(start_date, end_date)
    account.conversations.where(created_at: start_date..end_date).count
  end

  def count_agents(start_date, end_date)
    account.agents.where(created_at: start_date..end_date).count
  end

  def values(start_date, end_date)
    periods_in_range_for_group_by(group_by, start_date, end_date).map do |date|
      calculate_summary_for_period(date)
    end
  end

  def calculate_summary_for_period(date)
    periods = V2::BillingPeriod.new(group_by, date)
    extra_conversation_cost = sum_reporting_events_extra_conversations(periods.period_start, periods.period_end)
    extra_agent_cost = sum_reporting_events_extra_agents(periods.period_start, periods.period_end)
    total = calculate_total_price(extra_conversation_cost, extra_agent_cost)
    @total += total

    build_metrics_data(date, periods, extra_conversation_cost, extra_agent_cost, total)
  end

  def calculate_total_price(extra_conversation_cost, extra_agent_cost)
    product.price.to_f + extra_conversation_cost + extra_agent_cost
  end

  def build_metrics_data(date, periods, extra_conversation_cost, extra_agent_cost, total)
    V2::MetricsData.new({
                          date: date,
                          total_conversations: count_conversations(periods.period_start, periods.period_end),
                          total_agents: count_agents(periods.period_start, periods.period_end),
                          base_price: product.price.to_f,
                          extra_conversation_cost: extra_conversation_cost,
                          extra_agent_cost: extra_agent_cost,
                          total_price: total
                        }).to_h
  end

  def default_start_date
    Time.current.beginning_of_day - 3.months
  end

  def default_end_date
    Time.current.end_of_day
  end
end

class V2::ReportInvoicesBuilder
  include DateRangeHelper

  attr_reader :account, :params, :group_by, :product, :account_plan

  DEFAULT_GROUP_BY = 'month'.freeze

  def initialize(account, params)
    @account = account
    @account_plan = account.account_plan
    raise 'Account plan not found' unless @account_plan

    @product = account_plan.product
    @params = params
    @group_by = params[:group_by] || DEFAULT_GROUP_BY
  end

  def invoices_metrics
    values = []
    total_summary = initialize_total_summary

    date_range = compute_date_range
    return {} unless date_range

    start_date = date_range.first.to_date
    end_date = date_range.last.to_date

    periods_in_range_for_group_by(group_by, start_date, end_date).each do |period_start|
      period_metrics = calculate_metrics(period_start)
      update_total_summary(total_summary, period_metrics)
      values << period_metrics.to_h.merge(timestamp: period_start.to_time.to_i)
    end

    {
      values: values,
      total_summary: total_summary
    }
  end

  private

  def compute_date_range
    since = params[:since].present? ? parse_date_time(params[:since]) : default_start_date
    until_date = params[:until].present? ? parse_date_time(params[:until]) : default_end_date
    return if since.blank? || until_date.blank?

    since..until_date
  end

  def calculate_metrics(period_start)
    period_end = period_end_for_group_by(group_by, period_start)

    total_conversations = count_conversations(period_start, period_end)
    total_agents = count_agents(period_start, period_end)

    base_price = product.price.to_f

    product_details = extract_product_details(product.details)
    conversation_limit = product_details[:conversation_limit] + account_plan.extra_conversations
    agent_limit = product_details[:agent_limit] + account_plan.extra_agents

    extra_conversation_cost = calculate_extra_cost(
      total_conversations, conversation_limit, product_details[:extra_conversation_price]
    )
    extra_agent_cost = calculate_extra_cost(
      total_agents, agent_limit, product_details[:extra_agent_price]
    )
    total_price = base_price + extra_conversation_cost + extra_agent_cost

    V2::MetricsData.new(
      total_conversations: total_conversations,
      total_agents: total_agents,
      base_price: base_price,
      extra_conversation_cost: extra_conversation_cost,
      extra_agent_cost: extra_agent_cost,
      total_price: total_price
    )
  end

  def count_conversations(start_date, end_date)
    account.conversations.where(created_at: start_date..end_date).count
  end

  def count_agents(start_date, end_date)
    account.agents.where(created_at: start_date..end_date).count
  end

  def calculate_extra_cost(total_items, limit, extra_price)
    excess = [total_items - limit, 0].max
    excess * extra_price.to_f
  end

  def extract_product_details(details)
    {
      conversation_limit: details['number_of_conversations'].to_i,
      agent_limit: details['number_of_agents'].to_i,
      extra_conversation_price: details['extra_conversation_cost'].to_f,
      extra_agent_price: details['extra_agent_cost'].to_f
    }
  end

  def update_total_summary(total_summary, period_metrics)
    total_summary[:total_conversations] += period_metrics.total_conversations
    total_summary[:total_agents] += period_metrics.total_agents
    total_summary[:base_price] += period_metrics.base_price
    total_summary[:extra_conversation_cost] += period_metrics.extra_conversation_cost
    total_summary[:extra_agent_cost] += period_metrics.extra_agent_cost
    total_summary[:total_price] += period_metrics.total_price
  end

  def initialize_total_summary
    {
      total_conversations: 0,
      total_agents: 0,
      base_price: 0.0,
      extra_conversation_cost: 0.0,
      extra_agent_cost: 0.0,
      total_price: 0.0
    }
  end

  def default_start_date
    account.reporting_events.minimum(:created_at)&.to_datetime || DateTime.now.beginning_of_day
  end

  def default_end_date
    account.reporting_events.maximum(:created_at)&.to_datetime || DateTime.now.end_of_day
  end
end

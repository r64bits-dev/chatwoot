class V2::MetricsData
  attr_accessor :date, :total_conversations, :total_agents,
                :base_price, :extra_conversation_cost, :extra_agent_cost, :total_price

  def initialize(metrics_data)
    @date = metrics_data[:date]
    @total_conversations = metrics_data[:total_conversations]
    @total_agents = metrics_data[:total_agents]

    @base_price = metrics_data[:base_price]
    @extra_conversation_cost = metrics_data[:extra_conversation_cost]
    @extra_agent_cost = metrics_data[:extra_agent_cost]
    @total_price = metrics_data[:total_price]
  end

  def to_h
    {
      date: date,
      total_conversations: total_conversations,
      total_agents: total_agents,
      base_price: base_price,
      extra_conversation_cost: extra_conversation_cost,
      extra_agent_cost: extra_agent_cost,
      total_price: total_price
    }
  end
end

class V2::ProductDetails
  attr_reader :conversation_limit, :agent_limit, :extra_conversation_price, :extra_agent_price

  def initialize(details, account_plan)
    @details = details || {}
    @account_plan = account_plan
    extract_details
  end

  def total_conversation_limit
    conversation_limit + (@account_plan.extra_conversations || 0).to_i
  end

  def total_agent_limit
    agent_limit + (@account_plan.extra_agents || 0).to_i
  end

  private

  def extract_details
    @conversation_limit = (@details['number_of_conversations'] || 0).to_i
    @agent_limit = (@details['number_of_agents'] || 0).to_i
    @extra_conversation_price = (@details['extra_conversation_cost'] || 0.0).to_f
    @extra_agent_price = (@details['extra_agent_cost'] || 0.0).to_f
  end
end

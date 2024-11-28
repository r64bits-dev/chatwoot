module Enterprise::Account
  COST_MAPPING = {
    'incoming' => 'extra_message_incoming_cost',
    'outgoing' => 'extra_message_outgoing_cost'
  }.freeze

  def usage_limits
    {
      agents: agent_limits.to_i,
      inboxes: get_limits(:inboxes).to_i
    }
  end

  # if limit is exceeded, we will create a usage report
  def increase_usage_messages(message_type)
    return unless limit_exceeded?(:messages)

    update_limit_count(:messages)
    create_reporting_event("extra_messages_#{message_type}", extra_messages_cost(message_type))
  end

  private

  def agent_limits
    custom_attributes['subscribed_quantity'] || get_limits(:agents)
  end

  def get_limits(limit_name)
    increase_usage(limit_name) if account_plan.present? && limit_exceeded?(limit_name)

    # return self[:limits][limit_name.to_s] if self[:limits][limit_name.to_s].present?
    fetch_limit_from_config(limit_name) || ChatwootApp.max_limit
  end

  def limit_exceeded?(limit_name)
    product.present? &&
      product_details[name_of(limit_name)].present? &&
      send(limit_name).count > product_details[name_of(limit_name)]
  end

  def fetch_limit_from_config(limit_name)
    config_name = "ACCOUNT_#{limit_name.to_s.upcase}_LIMIT"
    config_value = GlobalConfig.get(config_name)[config_name]
    config_value.presence
  end

  def name_of(limit_name)
    "number_of_#{limit_name.to_s.pluralize.downcase}"
  end

  def extra_inboxes
    account_plan&.extra_inboxes || 0
  end

  def extra_agents
    account_plan&.extra_agents || 0
  end

  def extra_messages
    account_plan&.extra_messages || 0
  end

  def increase_usage(limit_name)
    update_limit_count(limit_name)
    create_usage_report(limit_name)
  end

  def update_limit_count(limit_name)
    case limit_name
    when :inboxes
      account_plan.update(extra_inboxes: extra_inboxes + 1)
    when :agents
      account_plan.update(extra_agents: extra_agents + 1)
    when :messages
      account_plan.update(extra_messages: extra_messages + 1)
    end
  end

  def create_usage_report(limit_name)
    case limit_name
    when :inboxes
      create_reporting_event('extra_inboxes', extra_conversation_cost)
    when :agents
      create_reporting_event('extra_agents', extra_agent_cost)
    else
      create_reporting_event(limit_name, yield)
    end
  end

  def create_reporting_event(event_name, event_value)
    ReportingEvent.create(
      account_id: id,
      name: event_name,
      value: event_value,
      event_start_time: Time.current,
      event_end_time: Time.current
    )
  end

  def product
    @product ||= account_plan.product
  end

  def product_details
    return {} if product.blank? || product.details.blank?

    @product_details ||= product.details.is_a?(String) ? JSON.parse(product.details) : product.details
  end

  def extra_agent_cost
    product.details['extra_agent_cost'].to_f || 0.0
  end

  def extra_conversation_cost
    product.details['extra_conversation_cost'].to_f || 0.0
  end

  def extra_messages_cost(message_type)
    product.details[COST_MAPPING[message_type]].to_f || 0.0
  end
end

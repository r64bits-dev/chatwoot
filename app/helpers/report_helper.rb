module ReportHelper
  private

  def scope
    case params[:type]
    when :account
      account
    when :inbox
      inbox
    when :agent
      user
    when :label
      label
    when :team
      team
    end
  end

  def conversations_count
    (get_grouped_values conversations).count
  end

  def incoming_messages_count
    (get_grouped_values incoming_messages).count
  end

  def outgoing_messages_count
    (get_grouped_values outgoing_messages).count
  end

  def resolutions_count
    (get_grouped_values resolutions).count
  end

  def conversations
    scope.conversations.with_agents_ids(agents_ids).where(account_id: account.id, created_at: range)
  end

  def incoming_messages
    scope.messages.with_agents_ids(agents_ids).where(account_id: account.id, created_at: range).incoming.unscope(:order)
  end

  def outgoing_messages
    scope.messages.with_agents_ids(agents_ids).where(account_id: account.id, created_at: range).outgoing.unscope(:order)
  end

  def tickets
    scope.tickets
         .with_agents_ids(agents_ids)
         .only_custom_attributes(custom_attributes)
         .where(account_id: account.id, created_at: range)
  end

  def resolutions
    scope.reporting_events
         .with_agents_ids(agents_ids)
         .joins(:conversation)
         .select(:conversation_id)
         .where(account_id: account.id, name: :conversation_resolved,
                conversations: { status: :resolved }, created_at: range)
         .distinct
  end

  def triggers
    grouped_reporting_events = get_grouped_values(scope.triggers, :createdAt)
    grouped_reporting_events.average(:createdAt)
  end

  def processed_triggers
    grouped_reporting_events = get_grouped_values(scope.triggers, :processedAt)
    grouped_reporting_events.average(:processedAt)
  end

  def avg_first_response_time
    grouped_reporting_events = (get_grouped_values scope.reporting_events.with_agents_ids(agents_ids).where(name: 'first_response',
                                                                                                            account_id: account.id))
    return grouped_reporting_events.average(:value_in_business_hours) if params[:business_hours]

    grouped_reporting_events.average(:value)
  end

  def reply_time
    grouped_reporting_events = (get_grouped_values scope.reporting_events.with_agents_ids(agents_ids).where(name: 'reply_time',
                                                                                                            account_id: account.id))
    return grouped_reporting_events.average(:value_in_business_hours) if params[:business_hours]

    grouped_reporting_events.average(:value)
  end

  def avg_resolution_time
    grouped_reporting_events = (get_grouped_values scope.reporting_events.with_agents_ids(agents_ids).where(name: 'conversation_resolved',
                                                                                                            account_id: account.id))
    return grouped_reporting_events.average(:value_in_business_hours) if params[:business_hours]

    grouped_reporting_events.average(:value)
  end

  def avg_resolution_time_summary
    reporting_events = scope.reporting_events
                            .with_agents_ids(agents_ids)
                            .where(name: 'conversation_resolved', account_id: account.id, created_at: range)
    avg_rt = if params[:business_hours].present?
               reporting_events.average(:value_in_business_hours)
             else
               reporting_events.average(:value)
             end

    return 0 if avg_rt.blank?

    avg_rt
  end

  def reply_time_summary
    reporting_events = scope.reporting_events
                            .with_agents_ids(agents_ids)
                            .where(name: 'reply_time', account_id: account.id, created_at: range)
    reply_time = params[:business_hours] ? reporting_events.average(:value_in_business_hours) : reporting_events.average(:value)

    return 0 if reply_time.blank?

    reply_time
  end

  def avg_first_response_time_summary
    reporting_events = scope.reporting_events
                            .with_agents_ids(agents_ids)
                            .where(name: 'first_response', account_id: account.id, created_at: range)
    avg_frt = if params[:business_hours].present?
                reporting_events.average(:value_in_business_hours)
              else
                reporting_events.average(:value)
              end

    return 0 if avg_frt.blank?

    avg_frt
  end

  def agents_ids
    params[:agents_ids]&.map(&:to_i) || []
  end

  def custom_attributes
    params[:custom_attributes] || []
  end
end

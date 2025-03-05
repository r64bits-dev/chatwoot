module Api::V1::ConversationsHelper
  def self.assign_open_conversations(current_user, current_account)
    open_inbox = fetch_open_inboxes(current_account)
    return { status: :error, message: 'no open conversations' } if open_inbox.empty?

    open_inbox.each do |inbox, conversations|
      next if inbox.nil?

      assign_conversations(inbox, conversations, current_user)
    end

    { status: :success }
  rescue StandardError => e
    Rails.logger.error("Error: #{e.message}\nBacktrace: #{e.backtrace.join("\n")}")
    { status: :error, message: e.message }
  end

  def self.fetch_open_inboxes(current_account)
    Conversation.open.where(assignee_id: nil)
                .where(account_id: current_account.id)
                .includes(:inbox)
                .where.not(inbox: nil)
                .group_by(&:inbox)
  end

  def self.assign_conversations(inbox, conversations, current_user)
    Rails.logger.info "assign_conversations - inbox_id: #{inbox.id}, conversations_count: #{conversations.count}"
    max_limit = inbox.max_assignment_limit_team_per_person.to_i
    user_ids = inbox.auto_assignment_only_this_agents_ids

    # Verifica se o agente está disponível
    return unless current_user.availability == 'online' # Ajuste conforme seu modelo
    return unless user_ids.present? && user_ids.include?(current_user.id)
    return unless max_limit.positive?

    assign_conversations_to_agent(inbox, conversations, current_user, max_limit)
  end

  def self.assign_conversations_to_agent(inbox, conversations, current_user, max_limit)
    user_assigned_count = inbox.conversations.open.where(assignee_id: current_user.id).count
    available_slots = max_limit - user_assigned_count
    return if available_slots <= 0

    Conversation.transaction do
      conversations.first(available_slots).each do |conversation|
        Rails.logger.info "Assigning conversation #{conversation.id} to agent #{current_user.id}"
        conversation.assignee_id = current_user.id
        conversation.save!
      end
    end
  end
end

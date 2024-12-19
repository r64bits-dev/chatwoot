module Api::V1::ConversationsHelper
  def self.assign_open_conversations(current_user, current_account)
    open_inbox = fetch_open_inboxes(current_account)

    return { error: 'no open conversations' } if open_inbox.blank?

    open_inbox.each do |inbox, conversations|
      assign_conversations(inbox, conversations, current_user)
    end

    true
  rescue StandardError => e
    Rails.logger.error e.message
    { error: e.message }
  end

  def self.fetch_open_inboxes(current_account)
    Conversation.open.where(assignee_id: nil)
                .includes(:inbox)
                .where(account_id: current_account.id)
                .group_by(&:inbox)
  end

  def self.assign_conversations(inbox, conversations, current_user)
    max_limit = inbox.max_assignment_limit_team_per_person.to_i
    user_ids = inbox.auto_assignment_only_this_agents_ids

    return if user_ids.blank? || !user_ids.include?(current_user.id)
    return unless max_limit.positive?

    assign_conversations_to_agent(inbox, conversations, current_user, max_limit)
  end

  def self.assign_conversations_to_agent(inbox, conversations, current_user, max_limit)
    user_assigned_count = inbox.conversations.open.where(assignee_id: current_user.id).count

    conversations.each do |conversation|
      break if user_assigned_count >= max_limit

      Rails.logger.info "Assigning conversation #{conversation.id} to agent #{current_user.id}"
      conversation.assignee_id = current_user.id

      user_assigned_count += 1 if conversation.save!
    end
  end
end

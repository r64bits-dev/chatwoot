module Api::V1::ConversationsHelper
  def self.assign_open_conversations(current_user, current_account)
    open_inbox = Conversation.open.where(assignee_id: nil)
                             .includes(:inbox)
                             .where(account_id: current_account.id)
                             .group_by(&:inbox)

    return { error: 'no open conversations' } if open_inbox.count.zero?

    open_inbox.each do |inbox, conversations|
      # check if has specific users to assign
      max_limit = inbox.max_assignment_limit_team_per_person.to_i
      user_ids = inbox.auto_assignment_only_this_agents_ids
      next if user_ids.blank? && user_ids.exclude?(current_user.id)

      assign_conversations_to_agent(inbox, conversations, current_user, max_limit) if max_limit.positive?
    end

    true
  rescue StandardError => e
    Rails.logger.error e.message
    { error: e.message }
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

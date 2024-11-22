module Api::V1::ConversationsHelper
  def self.assign_open_conversations(current_user, current_account)
    open_inbox = Conversation.open.where(assignee_id: nil)
                             .includes(:inbox)
                             .where(account_id: current_account.id)
                             .group_by(&:inbox)
    return { error: 'no open conversations' } if open_inbox.blank?

    open_inbox.each do |inbox, conversations|
      assign_conversations_to_agent(inbox, conversations, current_user)
    end

    true
  rescue StandardError => e
    Rails.logger.error e.message
    { error: e.message }
  end

  def self.assign_conversations_to_agent(inbox, conversations, current_user)
    max_limit = inbox.auto_assignment_config['max_assignment_limit'].to_i
    user_assigned_count = inbox.conversations.where(assignee_id: current_user.id).count

    conversations.each do |conversation|
      break if user_assigned_count >= max_limit

      Rails.logger.info "Assigning conversation #{conversation.id} to agent #{current_user.id}"
      conversation.assignee_id = current_user.id

      user_assigned_count += 1 if conversation.save!
    end
  end
end

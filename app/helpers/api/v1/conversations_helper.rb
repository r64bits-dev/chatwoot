module Api::V1::ConversationsHelper
  def self.assign_open_conversations(current_user, current_account)
    open_inbox = Conversation.open.where(assignee_id: nil)
                             .includes(:inbox)
                             .where(account_id: current_account.id)
                             .group_by(&:inbox)
    return { error: 'no open conversations' } if open_inbox.blank?

    open_inbox.each do |inbox, conversations|
      # check if has specific users to assign
      assign_conversations_to_users(inbox, conversations, current_user) if inbox.auto_assignment_only_this_agents_ids.present?

      max_limit = inbox.auto_assignment_config['max_assignment_limit_team_per_person'].to_i
      assign_conversations_to_agent(inbox, conversations, current_user, max_limit) if max_limit.positive?
    end

    true
  rescue StandardError => e
    Rails.logger.error e.message
    { error: e.message }
  end

  def self.assign_conversations_to_agent(inbox, conversations, current_user, max_limit)
    user_assigned_count = inbox.conversations.where(assignee_id: current_user.id).count

    conversations.each do |conversation|
      break if user_assigned_count >= max_limit

      Rails.logger.info "Assigning conversation #{conversation.id} to agent #{current_user.id}"
      conversation.assignee_id = current_user.id

      user_assigned_count += 1 if conversation.save!
    end
  end

  def self.assign_conversations_to_users(inbox, conversations, _current_user)
    user_ids = inbox.auto_assignment_only_this_agents_ids
    return if user_ids.blank?

    user_index = 0
    conversations.each do |conversation|
      user_id = user_ids[user_index]
      Rails.logger.info "Assigning conversation #{conversation.id} to agent #{user_id}"
      conversation.assignee_id = user_id

      if conversation.save!
        user_index = (user_index + 1) % user_ids.size # Avança para o próximo usuário de forma cíclica
      end
    end
  end
end

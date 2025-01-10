class AddSeeUnassignedConversationsToAccountUsersPermissions < ActiveRecord::Migration[7.0]
  def change
    change_column_default :account_users, :permissions, from: {
      'conversations': true,
      'reports': true,
      'contacts': true,
      'accounts': true,
      'peoples': true,
      'teams': true,
      'labels': true,
      'send_messages': true
    }, to: {
      'conversations': true,
      'reports': true,
      'contacts': true,
      'accounts': true,
      'peoples': true,
      'teams': true,
      'labels': true,
      'send_messages': true,
      'see_unassigned_conversations': true
    }
  end
end
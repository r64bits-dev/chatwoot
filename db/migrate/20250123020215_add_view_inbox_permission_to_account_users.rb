class AddViewInboxPermissionToAccountUsers < ActiveRecord::Migration[7.0]
  def up
    AccountUser.update_all("permissions = jsonb_set(permissions, '{view_inbox}', 'true')")

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
      :conversations => true,
      :reports => true,
      :contacts => true,
      :accounts => true,
      :peoples => true,
      :teams => true,
      :labels => true,
      :send_messages => true,
      :see_unassigned_conversations => true,
      'view_inbox' => true
    }
  end

  def down
    AccountUser.update_all("permissions = permissions - 'view_inbox'")

    change_column_default :account_users, :permissions, from: {
      :conversations => true,
      :reports => true,
      :contacts => true,
      :accounts => true,
      :peoples => true,
      :teams => true,
      :labels => true,
      :send_messages => true,
      'view_inbox' => true
    }, to: {
      'conversations': true,
      'reports': true,
      'contacts': true,
      'accounts': true,
      'peoples': true,
      'teams': true,
      'labels': true,
      'send_messages': true
    }
  end
end

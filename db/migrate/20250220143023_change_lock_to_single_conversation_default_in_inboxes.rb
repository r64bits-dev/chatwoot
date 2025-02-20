class ChangeLockToSingleConversationDefaultInInboxes < ActiveRecord::Migration[7.0]
  def change
    change_column_default :inboxes, :lock_to_single_conversation, from: false, to: true
    Inbox.update(lock_to_single_conversation: true)
  end
end

class UpdatePermissionsForUsers < ActiveRecord::Migration[7.0]
  def up
    AccountUser.update_all("permissions = jsonb_set(permissions, '{see_unassigned_conversations}', 'true')")
    AccountUser.update_all("permissions = jsonb_set(permissions, '{view_inbox}', 'true')")
  end

  def down
    AccountUser.update_all("permissions = permissions - 'see_unassigned_conversations'")
    AccountUser.update_all("permissions = permissions - 'view_inbox'")
  end
end

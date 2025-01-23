class AddViewInboxPermissionToAccountUsers < ActiveRecord::Migration[7.0]
  def up
    AccountUser.update_all("permissions = jsonb_set(permissions, '{view_inbox}', 'true')")
  end

  def down
    AccountUser.update_all("permissions = permissions - 'view_inbox'")
  end
end

class AddExtraMessagesToAccountPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :account_plans, :extra_messages, :integer, null: false, default: 0
  end

  def down
    remove_column :account_plans, :extra_messages
  end
end

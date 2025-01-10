class AddPinnedByToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :pinned_by, :integer, array: true, default: [], null: false
  end
end
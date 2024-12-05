class AddLevelToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :level, :integer, default: 1, null: false
  end
end

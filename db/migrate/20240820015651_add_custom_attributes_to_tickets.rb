class AddCustomAttributesToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :custom_attributes, :jsonb, default: {}
    add_index :tickets, :custom_attributes, using: :gin
  end
end

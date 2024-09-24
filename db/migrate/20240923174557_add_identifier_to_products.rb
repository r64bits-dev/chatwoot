class AddIdentifierToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :identifier, :string
    add_index :products, :identifier, unique: true
  end
end

class AddExternalErrorToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :external_error, :string
  end
end

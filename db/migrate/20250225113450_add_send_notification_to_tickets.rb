class AddSendNotificationToTickets < ActiveRecord::Migration[7.0] # Ajuste a versão conforme seu Rails
  def change
    add_column :tickets, :send_notification, :boolean, default: false, null: false
  end
end
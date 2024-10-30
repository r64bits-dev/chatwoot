class AddInitByAgentToInbox < ActiveRecord::Migration[7.0]
  def change
    add_column :inboxes, :init_by_agent, :boolean, default: false, null: false

    update_agent_initiated_inboxes
  end

  def update_agent_initiated_inboxes
    # Exemplo de condição específica para atualizar os valores
    ::Inbox.where(channel_type: 'Channel::WebWidget', csat_survey_enabled: false).find_in_batches do |inboxes_batch|
      inboxes_batch.each do |inbox|
        inbox.init_by_agent = false
        inbox.save!
      end
    end
  end
end

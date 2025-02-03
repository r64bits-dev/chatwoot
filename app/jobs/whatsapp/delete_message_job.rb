class Whatsapp::DeleteMessageJob < ApplicationJob
  queue_as :high

  def perform(message_id, params)
    message = Message.find(message_id)
    conversation = message.conversation
    channel = conversation.inbox.channel
    to = params[:conversation][:meta][:sender][:phone_number]

    if channel.provider == 'whatsapp_cloud'
      Whatsapp::Providers::WhatsappCloudService.new(whatsapp_channel: channel).delete_message(to, params[:message_id])
    else # rubocop:disable Style/EmptyElse
      nil
      # TODO: Add Whatsapp::Providers::Whatsapp360DialogService
      # Whatsapp::Providers::Whatsapp360DialogService.new(whatsapp_channel: channel).delete_message(params)
    end
  end
end

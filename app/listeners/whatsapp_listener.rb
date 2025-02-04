class WhatsappListener < BaseListener
  def message_updated(event)
    message, _account = extract_message_and_account(event)
    inbox = message.inbox
    return unless message.webhook_sendable?

    return unless inbox.channel_type == 'Channel::Whatsapp'
    return unless message.content_attributes[:deleted]

    payload = message.webhook_data.merge(event: __method__.to_s)

    payload[:phone_number] = inbox.channel.phone_number
    payload[:message_id] = message.source_id
    payload[:event] = :message_deleted

    Whatsapp::DeleteMessageJob.perform_later(message.id, payload)
  end
end

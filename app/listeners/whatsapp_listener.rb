class WhatsappListener < BaseListener
  def message_updated(event)
    message, _account = extract_message_and_account(event)
    inbox = message.inbox
    return unless message.webhook_sendable?

    return unless inbox.channel_type == 'Channel::Whatsapp'
    return unless message.content_attributes[:deleted]

    payload = message.webhook_data.merge(event: __method__.to_s)

    params = {
      phone_number: payload[:conversation][:meta][:sender][:phone_number],
      message_id: message.source_id,
      event: 'delete_message'
    }

    Webhooks::WhatsappEventsJob.perform_later(params)
  end
end

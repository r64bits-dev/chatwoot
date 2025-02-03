class Evolution::Message::DeleteMessageService < Evolution::BaseService
  def initialize(inbox_name:, message_id:, remote_jid:)
    @inbox_name = inbox_name
    @message_id = message_id
    @remote_jid = remote_jid

    super(inbox_name)
  end

  def perform
    delete_message
  end

  private

  def delete_message
    response = HTTParty.delete(delete_message_url,
                               body: { id: @message_id, fromMe: true, remoteJid: @remote_jid }.to_json,
                               headers: headers)
    response.parsed_response
  end

  def delete_message_url
    "#{evolution_webhook_url}/chat/deleteMessageForEveryone/#{@inbox_name}"
  end
end

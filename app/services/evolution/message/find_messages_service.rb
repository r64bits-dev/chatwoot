class Evolution::Message::FindMessagesService < Evolution::BaseService
  def perform
    find_messages
  end

  def find_message_by_text(text)
    find_messages&.find do |message|
      raw_text = extract_pure_text(message['message']['extendedTextMessage']['text'])
      raw_text == text.strip
    end
  rescue StandardError
    nil
  end

  private

  def find_messages
    response = HTTParty.post(find_messages_url, headers: headers)
    response.parsed_response
  rescue StandardError
    []
  end

  def find_messages_url
    "#{evolution_webhook_url}/chat/findMessages/#{@inbox_name}"
  end

  def extract_pure_text(full_text)
    full_text.match(/\*\w+:\*\n(.+)/m)&.captures&.first&.strip || full_text.strip
  end
end

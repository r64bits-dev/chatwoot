# app/views/api/v1/accounts/contacts/conversations/messages.json.jbuilder

json.payload do
  json.conversation_id @current_conversation&.id

  json.messages @messages do |message|
    json.partial! 'api/v1/models/message', formats: [:json], message: message
  end
end

json.meta do
  json.total_conversations @conversations.size
  current_idx = @conversations.index(@current_conversation)
  json.current_conversation_index(@current_conversation ? current_idx : nil)
  json.next_conversation_index(
    @current_conversation && (current_idx + 1) < @conversations.size ? (current_idx + 1) : nil
  )
  json.prev_conversation_index(
    @current_conversation && (current_idx - 1) >= 0 ? (current_idx - 1) : nil
  )
end

json.pagination do
  if @messages.present?
    json.current_page @messages.current_page
    json.next_page @messages.next_page
    json.prev_page @messages.prev_page
    json.total_pages @messages.total_pages
    json.total_count @messages.total_count
  else
    json.current_page 1
    json.next_page nil
    json.prev_page nil
    json.total_pages 1
    json.total_count 0
  end
end

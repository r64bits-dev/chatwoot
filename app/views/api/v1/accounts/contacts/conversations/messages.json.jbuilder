# app/views/api/v1/accounts/contacts/conversations/messages.json.jbuilder

json.payload do
  json.conversation_id @current_conversation&.id

  json.messages @messages do |message|
    json.partial! 'api/v1/models/message', formats: [:json], message: message
  end
end

json.pagination do
  json.current_page @messages.current_page
  json.next_page @messages.next_page
  json.prev_page @messages.prev_page
  json.total_pages @messages.total_pages
  json.total_count @messages.total_count
end

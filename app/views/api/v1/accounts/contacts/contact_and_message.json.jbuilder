json.payload do
  json.contact do
    json.partial! 'api/v1/models/contact', formats: [:json], resource: @contact, with_contact_inboxes: true
  end
  json.conversation do
    json.partial! 'api/v1/models/conversation', formats: [:json], conversation: @conversation
  end
  json.message do
    json.partial! 'api/v1/models/message', formats: [:json], message: @message
  end
end

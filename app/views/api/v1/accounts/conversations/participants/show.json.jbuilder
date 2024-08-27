json.meta do
  json.whatsapp? @conversation.whatsapp?
end

json.payload do
  json.array! @participants do |participant|
    json.partial! 'api/v1/models/agent', format: :json, resource: participant.user
  end
end

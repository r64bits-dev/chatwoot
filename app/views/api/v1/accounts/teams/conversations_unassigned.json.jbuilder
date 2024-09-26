if params[:details] == 'true'
  json.payload do
    json.array! @conversations do |conversation|
      json.partial! 'api/v1/models/conversation', resource: conversation
    end
  end
end

json.meta do
  json.total @conversations.count
end

json.payload do
  json.partial! 'api/v1/models/contact', formats: [:json],
                                         resource: @contact,
                                         conversation: @conversation,
                                         with_contact_inboxes: true
end

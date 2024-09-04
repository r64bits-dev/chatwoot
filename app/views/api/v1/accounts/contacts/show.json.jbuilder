json.payload do
  json.partial! 'api/v1/models/contact', formats: [:json],
                                         resource: @contact,
                                         ticket: @ticket,
                                         with_contact_inboxes: true
end

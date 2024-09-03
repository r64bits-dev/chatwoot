json.additional_attributes resource.additional_attributes
json.availability_status resource.availability_status
json.email resource.email
json.id resource.id

if defined?(ticket) && ticket.present?
  json.name "#{resource.name}##{ticket.id}"
else
  json.name resource.name
end

json.phone_number resource.phone_number
json.identifier resource.identifier
json.thumbnail resource.avatar_url
json.custom_attributes resource.custom_attributes
json.last_activity_at resource.last_activity_at.to_i if resource[:last_activity_at].present?
json.created_at resource.created_at.to_i if resource[:created_at].present?


# we only want to output contact inbox when its /contacts endpoints
if defined?(with_contact_inboxes) && with_contact_inboxes.present?
  json.contact_inboxes do
    json.array! resource.contact_inboxes do |contact_inbox|
      json.partial! 'api/v1/models/contact_inbox', formats: [:json], resource: contact_inbox
    end
  end
end

json.additional_attributes resource&.additional_attributes || {}
json.availability_status resource&.availability_status || 'offline'
json.email resource&.email if resource&.email.present?
json.id resource&.id if resource&.id.present?
if defined?(conversation) && conversation.present?
  json.team_name conversation.team&.try(:name)
  json.name "#{resource&.name}##{conversation.tickets&.last&.id}"
else
  json.name resource&.name
end

json.phone_number resource&.phone_number if resource&.phone_number.present?
json.identifier resource&.identifier if resource&.identifier.present?
json.thumbnail resource&.avatar_url if resource&.avatar_url.present?
json.custom_attributes resource&.custom_attributes || {}
json.last_activity_at resource&.last_activity_at.to_i if resource&.try(:last_activity_at).present?
json.created_at resource&.created_at.to_i if resource&.try(:created_at).present?

# we only want to output contact inbox when its /contacts endpoints
if defined?(with_contact_inboxes) && with_contact_inboxes.present?
  json.contact_inboxes do
    json.array! resource&.contact_inboxes do |contact_inbox|
      json.partial! 'api/v1/models/contact_inbox', formats: [:json], resource: contact_inbox
    end
  end
end

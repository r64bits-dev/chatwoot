class Evolution::FindParticipantsService < Evolution::BaseService
  def initialize(inbox_name, group_id)
    @inbox_name = inbox_name
    @group_id = group_id

    super(inbox_name)
  end

  def perform
    all_contacts = find_all_contacts
    participants = find_group_infos['participants']

    validate_response(participants, all_contacts)

    update_participants_with_contact_info(participants, all_contacts)
  end

  private

  def validate_response(participants, all_contacts)
    [] unless participants.present? && all_contacts.present?
    [] unless participants.is_a?(Array) && all_contacts.is_a?(Array)
  end

  def update_participants_with_contact_info(participants, all_contacts)
    participants.each do |participant|
      contact = find_contact_for_participant(participant, all_contacts)
      participant['phone'] = extract_phone_from_id(participant['id'])
      update_participant_details(participant, contact)
    end
  end

  def find_contact_for_participant(participant, all_contacts)
    all_contacts.find { |c| c.is_a?(Hash) && c['id'] == participant['id'] }
  end

  def extract_phone_from_id(participant_id)
    participant_id.split('@').first
  end

  def update_participant_details(participant, contact)
    if contact
      participant['name'] = contact['pushName'] || 'Nome não encontrado'
      participant['thumbnail'] = contact['profilePictureUrl']
    else
      participant['name'] = 'Nome não encontrado'
      participant['thumbnail'] = nil
    end
  end

  def find_group_infos
    response = HTTParty.get(find_group_infos_url, headers: headers)
    response.parsed_response
  end

  def find_all_contacts
    response = HTTParty.post(find_all_contacts_url, headers: headers)
    response.parsed_response
  end

  def find_group_infos_url
    "#{evolution_api_url}/group/findGroupInfos/#{@inbox_name}?groupJid=#{@group_id}"
  end

  def find_all_contacts_url
    "#{evolution_api_url}/chat/findContacts/#{@inbox_name}"
  end
end

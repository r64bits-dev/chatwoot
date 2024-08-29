class Evolution::FindParticipantsService
  def initialize(inbox_name, group_id)
    @group_id = group_id
    @inbox_name = inbox_name
  end

  def perform
    response = HTTParty.get(url, headers: headers)
    response.parsed_response
  end

  private

  def url
    "#{evolution_api_url}/group/findGroupInfos/#{@inbox_name}?groupJid=#{@group_id}"
  end

  def headers
    {
      'apiKey': ENV.fetch('EVOLUTION_API_TOKEN', nil),
      'Content-Type': 'application/json'
    }
  end

  def evolution_api_url
    ENV.fetch('EVOLUTION_API_URL', nil)
  end
end

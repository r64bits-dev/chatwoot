class Evolution::BlockContactService
  attr_reader :inbox_name, :phone_number

  def initialize(inbox_name, phone_number)
    @inbox_name = inbox_name
    @phone_number = phone_number
  end

  def perform
    response = HTTParty.post(url,
                             body: {
                               number: phone_number,
                               block: true
                             }, headers: headers)
    response['success']
  end

  private

  def url
    "#{evolution_api_url}/chat/whatsappBlock/#{inbox_name}"
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

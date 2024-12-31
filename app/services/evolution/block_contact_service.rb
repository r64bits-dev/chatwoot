class Evolution::BlockContactService < Evolution::EvolutionBaseService
  attr_reader :inbox_name, :phone_number

  def initialize(inbox_name, phone_number)
    @inbox_name = inbox_name
    @phone_number = phone_number
    super
  end

  # @override
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
end

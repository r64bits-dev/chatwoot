class Evolution::BaseService
  def initialize(inbox_name)
    @inbox_name = inbox_name
  end

  def perform
    raise 'Not implemented'
  end

  private

  def headers
    {
      'apiKey': ENV.fetch('EVOLUTION_API_TOKEN', nil),
      'Content-Type': 'application/json'
    }
  end

  def evolution_api_url
    ENV.fetch('EVOLUTION_API_URL', nil)
  end

  def evolution_webhook_url
    ENV.fetch('EVOLUTION_API_WEBHOOK', nil)
  end
end

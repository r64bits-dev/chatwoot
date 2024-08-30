class Evolution::EvolutionBaseService
  # will be overriden by subclasses
  def perform; end

  protected

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

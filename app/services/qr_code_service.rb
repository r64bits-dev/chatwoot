class QrCodeService
  include HTTParty

  def initialize(params)
    @url = "https://#{params.dig("channel", "provider_config", "url")}.maisomni.com.br/instance/create"
    @body = {
      instanceName: params[:name],
      qrcode: true,
      chatwoot_account_id: Current.account.id,
      chatwoot_token: params.dig("channel", "provider_config", "apiKey"),
      chatwoot_url: "https://portal.brainitsolutions.com.br",
      chatwoot_sign_msg: false,
      chatwoot_reopen_conversation: params.dig("channel", "provider_config", "chatwoot_reopen_conversation"),
      chatwoot_conversation_pending: params.dig("channel", "provider_config", "chatwoot_conversation_pending")
    }
  end

  def call
    self.class.post(@url, headers: headers, body: @body.to_json)
  end

  private

  def headers
    { 'apikey' => 'B6D711FCDE4D4FD5936544120E713976', 'Content-Type' => 'application/json' }
  end
end

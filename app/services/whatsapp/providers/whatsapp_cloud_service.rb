class Whatsapp::Providers::WhatsappCloudService < Whatsapp::Providers::BaseService
  def send_message(phone_number, message)
    if message.attachments.present?
      send_attachment_message(phone_number, message)
    elsif message.content_type == 'input_select'
      send_interactive_text_message(phone_number, message)
    else
      send_text_message(phone_number, message)
    end
  end

  def send_template(phone_number, template_info)
    template = get_template(template_info[:name])

    request_payload = {
      messaging_product: 'whatsapp',
      to: format_phone_number(phone_number),
      template: template_body_parameters(template, template_info),
      type: 'template'
    }.to_json

    response = HTTParty.post(
      "#{phone_id_path}/messages",
      headers: api_headers,
      body: request_payload
    )

    Rails.logger.info "response: #{response.inspect} request payload: #{request_payload}"
    raise CustomExceptions::Account::ErrorReply unless response.success?

    process_response(response)
  end

  def delete_message(phone_number, message_id)
    response = HTTParty.post(
      "#{phone_id_path}/messages/#{message_id}",
      headers: api_headers,
      body: {
        'type': 'delete',
        'to': format_phone_number(phone_number),
        'client': @whatsapp_channel.provider_config['api_key']
      }.to_json
    )

    Rails.logger.info "response: #{response.inspect} request payload: #{request_payload}"
    raise CustomExceptions::Account::ErrorReply unless response.success?

    process_response(response)
  end

  def get_template(template_name)
    whatsapp_channel.message_templates.find { |template| template['name'] == template_name }
  end

  def sync_templates
    # ensuring that channels with wrong provider config wouldn't keep trying to sync templates
    whatsapp_channel.mark_message_templates_updated
    templates = fetch_whatsapp_templates("#{business_account_path}/message_templates?access_token=#{whatsapp_channel.provider_config['api_key']}")
    whatsapp_channel.update(message_templates: templates, message_templates_last_updated: Time.now.utc) if templates.present?
  end

  def fetch_whatsapp_templates(url)
    response = HTTParty.get(url)
    Rails.logger.info response.body
    return [] unless response.success?

    next_url = next_url(response)

    return response['data'] + fetch_whatsapp_templates(next_url) if next_url.present?

    response['data']
  end

  def next_url(response)
    response['paging'] ? response['paging']['next'] : ''
  end

  def validate_provider_config?
    response = HTTParty.get("#{business_account_path}/message_templates?access_token=#{whatsapp_channel.provider_config['api_key']}")
    Rails.logger.info "#{response.inspect} response code: #{response.code} request provider config: #{whatsapp_channel.provider_config}"
    raise CustomExceptions::Account::InvalidProviderConfig unless response.success?

    response.success?
  end

  def api_headers
    { 'Authorization' => "Bearer #{whatsapp_channel.provider_config['api_key']}", 'Content-Type' => 'application/json' }
  end

  def media_url(media_id)
    "#{api_base_path}/v13.0/#{media_id}"
  end

  def api_base_path
    ENV.fetch('WHATSAPP_CLOUD_BASE_URL', 'https://graph.facebook.com')
  end

  # TODO: See if we can unify the API versions and for both paths and make it consistent with out facebook app API versions
  def phone_id_path
    "#{api_base_path}/v13.0/#{whatsapp_channel.provider_config['phone_number_id']}"
  end

  def business_account_path
    "#{api_base_path}/v14.0/#{whatsapp_channel.provider_config['business_account_id']}"
  end

  def send_text_message(phone_number, message)
    response = HTTParty.post(
      "#{phone_id_path}/messages",
      headers: api_headers,
      body: {
        messaging_product: 'whatsapp',
        context: whatsapp_reply_context(message),
        to: format_phone_number(phone_number),
        text: { body: message.content },
        type: 'text'
      }.to_json
    )

    Rails.logger.info response.inspect
    process_response(response)
  end

  def send_attachment_message(phone_number, message)
    attachment = message.attachments.first
    type = %w[image audio video].include?(attachment.file_type) ? attachment.file_type : 'document'
    type_content = {
      'link': attachment.download_url
    }
    type_content['caption'] = message.content unless %w[audio sticker].include?(type)
    type_content['filename'] = attachment.file.filename if type == 'document'
    response = HTTParty.post(
      "#{phone_id_path}/messages",
      headers: api_headers,
      body: {
        :messaging_product => 'whatsapp',
        :context => whatsapp_reply_context(message),
        'to' => phone_number,
        'type' => type,
        type.to_s => type_content
      }.to_json
    )

    process_response(response)
  end

  def send_interactive_text_message(phone_number, message)
    payload = create_payload_based_on_items(message)

    response = HTTParty.post(
      "#{phone_id_path}/messages",
      headers: api_headers,
      body: {
        messaging_product: 'whatsapp',
        to: phone_number,
        interactive: payload,
        type: 'interactive'
      }.to_json
    )

    binding.pry

    process_response(response)
  end

  def process_response(response)
    if response.success?
      response['messages'].first['id']
    else
      Rails.logger.error response.body
      nil
    end
  end

  def template_body_parameters(template, template_info)
    Rails.logger.info "template_info: #{template_info}"
    {
      name: template_info[:name],
      language: {
        policy: 'deterministic',
        code: template_info[:locale] || 'pt_BR'
      },
      components: build_components(template, template_info).concat(build_header_components(template_info[:headers]))
    }
  end

  def build_components(template, template_info)
    return [] if template_info[:parameters].blank?

    components = build_body_component(template, template_info[:parameters])
    components.concat(template_info[:buttons].map { |button| build_button_component(button) }) if template_info[:buttons].present?
    Rails.logger.info "build_components: #{components}"
    components
  end

  def build_body_component(template, parameters)
    [{
      type: 'body',
      parameters: parameters.map do |param|
        {
          type: 'text',
          text: param[:text].presence || ''
        }.tap do |hash|
          param_name = get_template_params_name_body(template)
          hash[:parameter_name] = param_name if param_name.present?
        end
      end
    }]
  end

  def build_header_components(headers)
    return [] if headers.blank?
    return [] if headers['type'].blank?

    parameters = headers['values'].each_with_object([]) do |value, acc|
      acc << {
        :type => headers['type'].downcase,
        headers['type'].downcase => { link: value }
      }
      acc
    end

    [{
      type: 'header',
      parameters: parameters
    }]
  end

  def build_button_component(buttons)
    {
      type: 'button',
      sub_type: 'URL',
      index: buttons[:index],
      parameters: buttons[:parameters].map { |param| { type: param['type'], text: param['text'] || '' } }
    }
  end

  def whatsapp_reply_context(message)
    reply_to = message.content_attributes[:in_reply_to_external_id]
    return nil if reply_to.blank?

    {
      message_id: reply_to
    }
  end

  def get_template_body(template)
    template['components'].find { |component| component['type'] == 'BODY' }
  end

  def get_template_params_name_body(template)
    body = get_template_body(template)
    return nil if body.blank?

    body.dig('example', 'body_text_named_params', 0, 'param_name')
  end
end

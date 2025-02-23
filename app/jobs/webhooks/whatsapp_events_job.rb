class Webhooks::WhatsappEventsJob < ApplicationJob
  include PhoneHelper

  queue_as :low

  def perform(params = {})
    channel = find_channel_from_whatsapp_business_payload(params)
    return raise('Channel is inactive') if channel_is_inactive?(channel)

    case channel.provider
    when 'whatsapp_cloud'
      Whatsapp::IncomingMessageWhatsappCloudService.new(inbox: channel.inbox, params: params).perform
    else
      Whatsapp::IncomingMessageService.new(inbox: channel.inbox, params: params).perform
    end
  end

  private

  def channel_is_inactive?(channel)
    return true if channel.blank?
    return true if channel.reauthorization_required?
    return true unless channel.account.active?

    false
  end

  def find_channel_by_url_param(params)
    return unless params[:phone_number]

    Channel::Whatsapp.find_by(phone_number: params[:phone_number])
  end

  def find_channel_from_whatsapp_business_payload(params)
    # for the case where facebook cloud api support multiple numbers for a single app
    # https://github.com/chatwoot/chatwoot/issues/4712#issuecomment-1173838350
    # we will give priority to the phone_number in the payload
    return get_channel_from_wb_payload(params) if params[:object] == 'whatsapp_business_account'

    find_channel_by_url_param(params)
  end

  def get_channel_from_wb_payload(wb_params)
    raw_phone_number = wb_params[:entry].first[:changes].first.dig(:value, :metadata, :display_phone_number)
    phone_number = format_phone_number(raw_phone_number)
    phone_number_without_nine = remove_extra_nine(phone_number)

    phone_numbers_to_search = [phone_number, phone_number_without_nine].uniq
    phone_number_id = wb_params[:entry].first[:changes].first.dig(:value, :metadata, :phone_number_id)

    channel = Channel::Whatsapp.where(phone_number: phone_numbers_to_search).first

    channel if channel && channel.provider_config['phone_number_id'] == phone_number_id
  end
end

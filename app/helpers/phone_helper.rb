module PhoneHelper
  def format_phone_number(phone_number)
    return phone_number if phone_number.blank?

    phone_number.gsub!(/[^\d]/, '')
    phone_number = "55#{phone_number}" if !phone_number.start_with?('55') && (phone_number.length == 10 || phone_number.length == 11)
    phone_number = "+#{phone_number}" unless phone_number.start_with?('+')

    phone_number
  end
end

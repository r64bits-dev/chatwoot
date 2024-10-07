module PhoneHelper
  def format_phone_number(phone_number)
    return phone_number if phone_number.blank?

    phone_number.gsub!(/[^\d]/, '')
    phone_number.gsub!(/^(\d{3})(\d{3})(\d{4})$/, '\\1-\\2-\\3')
    phone_number
  end
end

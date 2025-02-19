module PhoneHelper
  def format_phone_number(phone_number)
    return phone_number if phone_number.blank?

    phone_number
      .then { |n| clean_number(n) }
      .then { |n| ensure_country_code(n) }
      .then { |n| ensure_plus_prefix(n) }
      .then { |n| ensure_nine_digit(n) }
  end

  private

  def clean_number(number)
    number.gsub(/[^\d]/, '')
  end

  def ensure_country_code(number)
    return "55#{number}" if !number.start_with?('55') && [10, 11].include?(number.length)

    number
  end

  def ensure_plus_prefix(number)
    number.start_with?('+') ? number : "+#{number}"
  end

  def ensure_nine_digit(number)
    return number unless number.start_with?('+55')

    digits = number[1..]
    ddd, subscriber = extract_ddd_and_subscriber(digits)

    return number unless needs_nine_digit?(subscriber)

    insert_nine_digit(number, ddd)
  end

  def extract_ddd_and_subscriber(digits)
    case digits.length
    when 10
      [digits[0, 2], digits[2..]]
    when 12
      [digits[2, 2], digits[4..]]
    else
      [nil, nil]
    end
  end

  def needs_nine_digit?(subscriber)
    subscriber && subscriber.length == 8 && subscriber[0].match?(/[6-9]/)
  end

  def insert_nine_digit(number, ddd)
    position = ddd ? number.index(ddd) + 2 : 3
    number.insert(position, '9')
  end

  def remove_extra_nine(number)
    return number unless number.start_with?('+55')

    digits = number[1..]
    case digits.length
    when 11
      number[3] == '9' ? number[0, 3] + number[4..] : number
    when 13
      number[5] == '9' ? number[0, 5] + number[6..] : number
    else
      number
    end
  end
end

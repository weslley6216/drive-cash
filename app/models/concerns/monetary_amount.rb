module MonetaryAmount
  extend ActiveSupport::Concern

  def amount=(value)
    value = normalize_brazilian_decimal(value) if value.is_a?(String)

    super(value)
  end

  private

  def normalize_brazilian_decimal(text)
    cleaned = text.gsub(/[^\d.,]/, '')
    return cleaned if cleaned.exclude?(',') && cleaned.exclude?('.')

    last_separator = cleaned.rindex(/[.,]/)
    integer_part = cleaned[0...last_separator].delete('.,')
    decimal_part = cleaned[(last_separator + 1)..]

    if decimal_part.length == 3 && cleaned.count('.,') == 1
      "#{integer_part}#{decimal_part}"
    else
      "#{integer_part}.#{decimal_part}"
    end
  end
end

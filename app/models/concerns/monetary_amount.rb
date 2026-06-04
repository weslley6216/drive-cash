module MonetaryAmount
  extend ActiveSupport::Concern

  def amount=(value)
    if value.is_a?(String)
      cleaned = value.gsub(/[^\d.,]/, '')
      value = cleaned.include?(',') ? cleaned.delete('.').tr(',', '.') : cleaned
    end

    super(value)
  end
end

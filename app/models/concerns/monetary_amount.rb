module MonetaryAmount
  extend ActiveSupport::Concern

  def amount=(value)
    if value.is_a?(String)
      value = value.gsub(/[^\d.,]/, '').gsub(',', '.')
    end

    super(value)
  end
end

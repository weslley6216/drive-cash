module Formatting
  include ActionView::Helpers::NumberHelper

  def format_currency(value)
    number_to_currency(value, unit: 'R$ ', separator: ',', delimiter: '.', precision: 2)
  end

  def format_percentage(value)
    number_with_precision(value, precision: 1)
  end

  def format_decimal(value)
    number_with_precision(value, precision: 1)
  end
end

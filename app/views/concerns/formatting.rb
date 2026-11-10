module Formatting
  include ActionView::Helpers::NumberHelper

  def format_currency(value)
    number_to_currency(value, unit: 'R$ ', format: '%u%n', separator: ',', delimiter: '.', precision: 2)
  end

  def format_currency_short(value)
    number_to_currency(value, unit: 'R$ ', format: '%u%n', separator: ',', delimiter: '.', precision: 0)
  end

  def format_percentage(value)
    number_with_precision(value, precision: 1)
  end

  def month_abbr(number)
    I18n.t('date.abbr_month_names')[number].capitalize
  end
end

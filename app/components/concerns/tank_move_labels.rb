module TankMoveLabels
  private

  def credit?
    @move[:kind] == :credit
  end

  def filter_kind
    credit? ? 'fill' : 'route'
  end

  def label
    return @move[:full_tank] ? t('vehicle.moves.full_tank') : t('vehicle.moves.partial_fill') if credit?

    @move[:description].presence || t('vehicle.moves.route')
  end

  def sub_label
    credit? ? fill_detail : t('vehicle.moves.fuel_expense')
  end

  def fill_detail
    parts = [@move[:vendor]].compact
    parts << "#{helpers.number_with_precision(@move[:liters], precision: 1, separator: ',', delimiter: '.')} L" if @move[:liters]
    parts << "#{format_currency(@move[:price_per_liter])}/L" if @move[:price_per_liter]
    parts.join(' · ')
  end

  def date_label
    date = @move[:date]
    return t('vehicle.moves.today') if date == Date.current
    return t('vehicle.moves.yesterday') if date == Date.current - 1

    helpers.l(date, format: '%d %b')
  end

  def amount_tone
    credit? ? 'text-blue-700' : 'text-red-700'
  end

  def amount_sign
    credit? ? '+' : '−'
  end
end

module SignedPercent
  def signed_percent(value)
    sign = value.negative? ? '−' : '+'
    "#{sign}#{number_with_precision(value.abs, precision: 1, separator: ',')}%"
  end
end

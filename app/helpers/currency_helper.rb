module CurrencyHelper
  def format_currency(amount)
    "R$ #{format('%.2f', amount.to_f).gsub('.', ',')}"
  end
end

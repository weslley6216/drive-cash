module Dashboard
  module MonthlyTotals
    # Soma `amount` por mês do `scope`, retornando array de 12 posições (jan..dez).
    def monthly_totals
      grouped = scope.group(Arel.sql('EXTRACT(MONTH FROM date)::int')).sum(:amount)
      (1..12).map { |month| grouped[month].to_f }
    end
  end
end

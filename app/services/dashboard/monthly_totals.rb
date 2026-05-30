module Dashboard
  module MonthlyTotals
    def monthly_totals
      grouped = scope.group(Arel.sql('EXTRACT(MONTH FROM date)::int')).sum(:amount)
      (1..12).map { |month| grouped[month].to_f }
    end
  end
end

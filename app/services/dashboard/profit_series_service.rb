module Dashboard
  class ProfitSeriesService
    def initialize(year:, month: nil)
      @year = year
      @month = month
    end

    def monthly
      @monthly ||= begin
        year_earnings = EarningsCalculator.new(Earning.for_year(year)).monthly_totals
        year_expenses = ExpensesCalculator.new(Expense.for_year(year).paid_only).monthly_totals
        year_earnings.zip(year_expenses).map { |earn, exp| (earn - exp).round(2) }
      end
    end

    def daily
      return nil unless month

      days_in_month = Date.new(year.to_i, month.to_i, -1).day
      earn_by_day = Earning.for_year(year).for_month(month)
                           .group(Arel.sql('EXTRACT(DAY FROM date)::int')).sum(:amount)
      exp_by_day  = Expense.for_year(year).paid_only.for_month(month)
                           .group(Arel.sql('EXTRACT(DAY FROM date)::int')).sum(:amount)

      (1..days_in_month).map { |d| (earn_by_day[d].to_f - exp_by_day[d].to_f).round(2) }
    end

    private

    attr_reader :year, :month
  end
end

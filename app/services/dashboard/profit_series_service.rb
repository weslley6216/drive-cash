module Dashboard
  class ProfitSeriesService
    def initialize(year:, month: nil, user: Current.user)
      @year = year
      @month = month
      @user = user
    end

    def monthly
      @monthly ||= begin
        year_earnings = EarningsCalculator.new(@user.earnings.in_period(year)).monthly_totals
        year_expenses = ExpensesCalculator.new(@user.expenses.paid_in_period(year)).monthly_totals
        year_earnings.zip(year_expenses).map { |earn, exp| (earn - exp).round(2) }
      end
    end

    def daily
      return nil unless month

      days_in_month = Date.new(year.to_i, month.to_i, -1).day
      earn_by_day = @user.earnings.in_period(year, month)
                         .group(Arel.sql('EXTRACT(DAY FROM date)::int')).sum(:amount)
      exp_by_day  = @user.expenses.paid_in_period(year, month)
                         .group(Arel.sql('EXTRACT(DAY FROM date)::int')).sum(:amount)

      (1..days_in_month).map { |day| (earn_by_day[day].to_f - exp_by_day[day].to_f).round(2) }
    end

    private

    attr_reader :year, :month
  end
end

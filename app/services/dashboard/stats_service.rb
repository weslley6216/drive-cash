module Dashboard
  class StatsService
    def initialize(year: Date.current.year, month: nil, through_month: nil, user: Current.user)
      @year = year
      @month = month
      @through_month = through_month
      @user = user
    end

    def call
      earnings_data = memoized_earnings_data
      expenses_data = memoized_expenses_data

      earnings_total = earnings_data[:total]
      expenses_total = expenses_data[:total]
      days_worked   = earnings_data[:days_count]
      profit_value  = earnings_total - expenses_total

      {
        earnings: earnings_total,
        expenses: expenses_total,
        profit: profit_value,
        days: days_worked,

        earnings_avg_month: earnings_data[:avg_per_month],
        earnings_avg_day: earnings_data[:avg_per_day],
        expenses_percent: expenses_percent(earnings_total, expenses_total),
        profit_per_day: profit_per_day(profit_value, days_worked),
        days_avg_month: days_avg_month(days_worked),
        days_avg_week: days_avg_week(days_worked),

        trips: earnings_data[:trips_count],
        trips_avg_month: trips_avg_month(earnings_data[:trips_count]),
        trips_avg_day: trips_avg_day(earnings_data[:trips_count], days_worked),

        monthly_profit_series: profit_series.monthly,
        daily_profit_series: profit_series.daily,
        change_percent: change_percent
      }
    end

    private

    attr_reader :year, :month, :through_month

    def memoized_earnings_data
      @memoized_earnings_data ||= earnings_calculator.call
    end

    def memoized_expenses_data
      @memoized_expenses_data ||= expenses_calculator.call
    end

    def earnings_scope
      @earnings_scope ||= begin
        scope = @user.earnings.for_year(year)
        scope = scope.for_month(month) if month
        scope = scope.where('EXTRACT(MONTH FROM date) <= ?', through_month) if through_month && !month
        scope
      end
    end

    def expenses_scope
      @expenses_scope ||= begin
        scope = @user.expenses.for_year(year).paid_only
        scope = scope.for_month(month) if month
        scope = scope.where('EXTRACT(MONTH FROM date) <= ?', through_month) if through_month && !month
        scope
      end
    end

    def earnings_calculator
      @earnings_calculator ||= EarningsCalculator.new(earnings_scope)
    end

    def expenses_calculator
      @expenses_calculator ||= ExpensesCalculator.new(expenses_scope)
    end

    def expenses_percent(earnings, expenses)
      return 0 if earnings.zero?
      (expenses / earnings * 100).round(1)
    end

    def profit_per_day(profit_value, days)
      return 0 if days.zero?
      profit_value / days
    end

    def earnings_months_count
      @earnings_months_count ||= ScopeMonthCounter.count_for(earnings_scope)
    end

    def days_avg_month(days)
      months = earnings_months_count
      return 0 if months.zero?
      (days.to_f / months).round(1)
    end

    def days_avg_week(days_worked)
      return 0 if month.blank? || days_worked.zero?

      days_in_month = Time.days_in_month(month.to_i, year.to_i)
      weeks_count = days_in_month / 7.0

      (days_worked / weeks_count).round
    end

    def trips_avg_month(trips)
      months = earnings_months_count
      return 0 if months.zero?

      (trips.to_f / months).round
    end

    def trips_avg_day(trips, days)
      return 0 if days.zero?

      (trips.to_f / days).round
    end

    def profit_series
      @profit_series ||= ProfitSeriesService.new(year: year, month: month, user: @user)
    end

    def change_percent
      return nil unless month

      current_index  = month.to_i - 1
      previous_index = current_index - 1
      return nil if previous_index.negative?

      series = profit_series.monthly
      current_profit  = series[current_index].to_f
      previous_profit = series[previous_index].to_f
      return nil if previous_profit.zero?

      ((current_profit - previous_profit) / previous_profit.abs * 100).round(1)
    end
  end
end

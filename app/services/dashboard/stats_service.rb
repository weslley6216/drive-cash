module Dashboard
  class StatsService
    def initialize(year: Date.current.year, month: nil, through_month: nil, user: Current.user)
      @year = year
      @month = month
      @through_month = through_month
      @user = user
    end

    def metrics
      earnings_data = memoized_earnings_data
      expenses_data = memoized_expenses_data
      earnings_total = earnings_data[:total]
      expenses_total = expenses_data[:total]
      days_worked = earnings_data[:days_count]
      trips = earnings_data[:trips_count]
      profit_value = earnings_total - expenses_total

      {
        earnings:           earnings_total,
        expenses:           expenses_total,
        profit:             profit_value,
        days:               days_worked,
        earnings_avg_month: earnings_data[:avg_per_month],
        earnings_avg_day:   earnings_data[:avg_per_day],
        trips:              trips
      }.merge(derived_metrics(earnings_total, expenses_total, profit_value, days_worked, trips))
    end

    def call
      metrics.merge(
        monthly_profit_series: profit_series.monthly,
        daily_profit_series:   profit_series.daily,
        change_percent:        change_percent
      )
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
      @earnings_scope ||= scoped(@user.earnings.in_period(year, month))
    end

    def expenses_scope
      @expenses_scope ||= scoped(@user.expenses.paid_in_period(year, month))
    end

    def scoped(relation)
      return relation unless year_to_date?

      relation.where('EXTRACT(MONTH FROM date) <= ?', through_month)
    end

    def year_to_date?
      through_month.present? && month.nil?
    end

    def earnings_calculator
      @earnings_calculator ||= EarningsCalculator.new(earnings_scope)
    end

    def expenses_calculator
      @expenses_calculator ||= ExpensesCalculator.new(expenses_scope)
    end

    def derived_metrics(earnings, expenses, profit, days, trips)
      DerivedMetrics.new(
        earnings:     earnings,
        expenses:     expenses,
        profit:       profit,
        days:         days,
        trips:        trips,
        months_count: earnings_months_count,
        year:         year,
        month:        month
      ).call
    end

    def earnings_months_count
      @earnings_months_count ||= ScopeMonthCounter.count_for(earnings_scope)
    end

    def profit_series
      @profit_series ||= ProfitSeriesService.new(year: year, month: month, user: @user)
    end

    def change_percent
      return nil unless month

      current_index = month.to_i - 1
      previous_index = current_index - 1
      return nil if previous_index.negative?

      series = profit_series.monthly
      PercentChange.between(series[current_index], series[previous_index])
    end
  end
end

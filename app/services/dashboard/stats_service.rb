module Dashboard
  class StatsService
    def initialize(year: Date.current.year, month: nil, user: Current.user, ledger: nil)
      @year = year
      @month = month
      @user = user
      @ledger = ledger || YearLedger.new(user: user, year: year)
    end

    def metrics
      earnings_data = memoized_earnings_data
      earnings_total = earnings_data[:total]
      expenses_total = ledger.spent_in(month)
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

    attr_reader :year, :month, :ledger

    def memoized_earnings_data
      @memoized_earnings_data ||= EarningsCalculator.new(ledger.earning_days(month)).call
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
      memoized_earnings_data[:months_count]
    end

    def profit_series
      @profit_series ||= ProfitSeriesService.new(year: year, month: month, user: @user, ledger: ledger)
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

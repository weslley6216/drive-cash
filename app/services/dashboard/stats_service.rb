module Dashboard
  class StatsService
    def initialize(year: Date.current.year, month: nil)
      @year = year
      @month = month
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
        days_avg_month: days_avg_month(days_worked, earnings_data[:total]),
        days_avg_week: days_avg_week(days_worked),

        trips: earnings_data[:trips_count],
        trips_avg_month: trips_avg_month(earnings_data[:trips_count], earnings_data[:total]),
        trips_avg_day: trips_avg_day(earnings_data[:trips_count], days_worked),

        monthly_profit_series: monthly_profit_series,
        daily_profit_series: daily_profit_series,
        change_percent: change_percent
      }
    end

    private

    attr_reader :year, :month

    def memoized_earnings_data
      @memoized_earnings_data ||= earnings_calculator.call
    end

    def memoized_expenses_data
      @memoized_expenses_data ||= expenses_calculator.call
    end

    def earnings_scope
      @earnings_scope ||= begin
        scope = Earning.for_year(year)
        scope = scope.for_month(month) if month
        scope
      end
    end

    def expenses_scope
      @expenses_scope ||= begin
        scope = Expense.for_year(year).paid_only
        scope = scope.for_month(month) if month
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

    def days_avg_month(days, earnings_total)
      months = distinct_months_count(earnings_total)
      return 0 if months.zero?
      (days.to_f / months).round(1)
    end

    def days_avg_week(days_worked)
      return 0 if month.blank? || days_worked.zero?

      days_in_month = Time.days_in_month(month.to_i, year.to_i)
      weeks_count = days_in_month / 7.0

      (days_worked / weeks_count).round
    end

    def trips_avg_month(trips, earnings_total)
      months = distinct_months_count(earnings_total)
      return 0 if months.zero?

      (trips.to_f / months).round
    end

    def trips_avg_day(trips, days)
      return 0 if days.zero?

      (trips.to_f / days).round
    end

    def daily_profit_series
      return nil unless month

      days_in_month = Date.new(year.to_i, month.to_i, -1).day
      earn_by_day = Earning.for_year(year).for_month(month)
                           .group(Arel.sql('EXTRACT(DAY FROM date)::int')).sum(:amount)
      exp_by_day  = Expense.for_year(year).paid_only.for_month(month)
                           .group(Arel.sql('EXTRACT(DAY FROM date)::int')).sum(:amount)

      (1..days_in_month).map { |d| (earn_by_day[d].to_f - exp_by_day[d].to_f).round(2) }
    end


    def monthly_profit_series
      @monthly_profit_series ||= begin
        year_earnings = EarningsCalculator.new(Earning.for_year(year)).monthly_totals
        year_expenses = ExpensesCalculator.new(Expense.for_year(year).paid_only).monthly_totals
        year_earnings.zip(year_expenses).map { |earn, exp| (earn - exp).round(2) }
      end
    end

    def change_percent
      return nil unless month

      current_index  = month.to_i - 1
      previous_index = current_index - 1
      return nil if previous_index.negative?

      series = monthly_profit_series
      current_profit  = series[current_index].to_f
      previous_profit = series[previous_index].to_f
      return nil if previous_profit.zero?

      ((current_profit - previous_profit) / previous_profit.abs * 100).round(1)
    end

    def distinct_months_count(earnings_total)
      return 1 unless earnings_total > 0

      earnings_scope
        .pluck(Arel.sql("DISTINCT TO_CHAR(date, 'YYYY-MM')"))
        .count
        .clamp(1, Float::INFINITY)
    end
  end
end

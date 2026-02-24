module Dashboard
  class StatsService
    def initialize(year: Date.current.year, month: nil)
      @year = year
      @month = month
    end

    def call
      earnings_data = earnings_calculator.call
      expenses_data = expenses_calculator.call

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

        earnings_by_platform: earnings_data[:by_platform],
        expenses_by_category: expenses_data[:by_category],
        top_expense_vendors: expenses_data[:top_vendors]
      }
    end

    private

    attr_reader :year, :month

    def earnings_scope
      @earnings_scope ||= begin
        scope = Earning.for_year(year)
        scope = scope.for_month(month) if month
        scope
      end
    end

    def expenses_scope
      @expenses_scope ||= begin
        scope = Expense.for_year(year)
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

    def days_avg_month(days)
      months = distinct_months_count
      return 0 if months.zero?
      (days.to_f / months).round(1)
    end

    def days_avg_week(days_worked)
      return 0 if month.blank? || days_worked.zero?

      year_int = year.to_i
      month_int = month.to_i

      return 0 if year_int.zero? || month_int.zero?

      days_in_month = Time.days_in_month(month_int, year_int)
      weeks_count = days_in_month / 7.0

      (days_worked / weeks_count).round
    end

    def distinct_months_count
      earnings_calculator.call[:total] > 0 ?
        earnings_scope.pluck(Arel.sql("DISTINCT TO_CHAR(date, 'YYYY-MM')")).count.clamp(1, Float::INFINITY) :
        1
    end

    def self.available_years
      Rails.cache.fetch('dashboard/available_years', expires_in: 1.hour) do
        earning_years = Earning.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::int'))
        expense_years = Expense.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::int'))

        years = (earning_years + expense_years).uniq.sort.reverse

        (years + [Date.current.year]).uniq.sort.reverse
      end
    end
  end
end

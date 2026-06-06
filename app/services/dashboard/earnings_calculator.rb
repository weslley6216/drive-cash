module Dashboard
  class EarningsCalculator
    include MonthlyTotals

    def initialize(scope)
      @scope = scope
    end

    def call
      {
        total: total_earnings,
        avg_per_month: avg_per_month,
        avg_per_day: avg_per_day,
        days_count: days_count,
        trips_count: total_trips
      }
    end

    private

    attr_reader :scope

    def total_earnings
      @total_earnings ||= scope.sum(:amount)
    end

    def days_count
      @days_count ||= scope.select(:date).distinct.count
    end

    def avg_per_month
      months = ScopeMonthCounter.count_for(scope)
      return 0 if months.zero?
      total_earnings / months
    end

    def avg_per_day
      return 0 if days_count.zero?
      total_earnings / days_count
    end

    def total_trips
      @total_trips ||= scope.sum(:trips_count)
    end
  end
end

module Dashboard
  class EarningsCalculator
    include ScopeMonthCounter

    def initialize(scope)
      @scope = scope
    end

    def call
      {
        total: total_earnings,
        avg_per_month: avg_per_month,
        avg_per_day: avg_per_day,
        by_platform: by_platform,
        days_count: days_count
      }
    end

    private

    attr_reader :scope

    def total_earnings
      @total_earnings ||= scope.sum(:amount)
    end

    def days_count
      @days_count ||= scope.where('amount > 0').select(:date).distinct.count
    end

    def avg_per_month
      months = distinct_months_count
      return 0 if months.zero?
      total_earnings / months
    end

    def avg_per_day
      return 0 if days_count.zero?
      total_earnings / days_count
    end

    def by_platform
      scope.group(:platform).sum(:amount)
    end
  end
end

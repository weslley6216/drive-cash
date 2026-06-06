module Dashboard
  class ExpensesCalculator
    include MonthlyTotals

    def initialize(scope)
      @scope = scope
    end

    def call
      {
        total: total_expenses,
        avg_per_month: avg_per_month,
        by_category: by_category
      }
    end

    private

    attr_reader :scope

    def total_expenses
      @total_expenses ||= scope.sum(:amount)
    end

    def avg_per_month
      months = ScopeMonthCounter.count_for(scope)
      return 0 if months.zero?
      total_expenses / months
    end

    def by_category
      scope.group(:category).sum(:amount)
    end
  end
end

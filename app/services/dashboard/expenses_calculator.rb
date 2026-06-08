module Dashboard
  class ExpensesCalculator
    include MonthlyTotals

    def initialize(scope)
      @scope = scope
    end

    def call
      {
        total: total_expenses,
        by_category: by_category
      }
    end

    private

    attr_reader :scope

    def total_expenses
      @total_expenses ||= scope.sum(:amount)
    end

    def by_category
      scope.group(:category).sum(:amount)
    end
  end
end

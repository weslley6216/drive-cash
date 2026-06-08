module Dashboard
  class ExpensesCalculator
    include MonthlyTotals

    def initialize(scope)
      @scope = scope
    end

    def call
      {
        total: total_expenses
      }
    end

    private

    attr_reader :scope

    def total_expenses
      @total_expenses ||= scope.sum(:amount)
    end
  end
end

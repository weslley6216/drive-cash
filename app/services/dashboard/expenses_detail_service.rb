module Dashboard
  class ExpensesDetailService < BaseDetailService
    private

    def base_scope
      Expense
    end

    def empty_scope
      Expense.none
    end

    def list_key
      :expenses
    end

    def by_month_key
      :expenses_by_month
    end
  end
end

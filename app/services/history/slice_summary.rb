module History
  class SliceSummary
    def initialize(slice:, user:, year:, month:)
      @slice = slice
      @query = SliceQuery.new(slice)
      @user = user
      @year = year
      @month = month
    end

    def call
      return mixed_summary if @slice.include_earnings? && @slice.include_expenses?
      return expenses_summary if @slice.include_expenses?

      earnings_summary
    end

    private

    def earnings_scope
      @query.earnings(@user.earnings.in_period(@year, @month))
    end

    def expenses_scope
      @query.expenses(@user.expenses.in_period(@year, @month))
    end

    def mixed_summary
      earnings_total = earnings_scope.sum(:amount)
      expenses_total = expenses_scope.sum(:amount)
      paid_expenses_total = expenses_scope.where(paid: true).sum(:amount)

      { kind: :mixed, earnings: earnings_total, expenses: expenses_total, net: earnings_total - paid_expenses_total }
    end

    def expenses_summary
      total = expenses_scope.sum(:amount)
      count = expenses_scope.count

      {
        kind:     :expenses,
        total:    total,
        count:    count,
        average:  average(total, count),
        pending:  expenses_scope.where(paid: false).sum(:amount),
        category: @slice.categories.one? ? @slice.categories.first : nil
      }
    end

    def earnings_summary
      total = earnings_scope.sum(:amount)
      count = earnings_scope.count

      { kind: :earnings, total: total, count: count, average: average(total, count), pending: 0, category: nil }
    end

    def average(total, count)
      count.zero? ? 0 : (total / count).round(2)
    end
  end
end

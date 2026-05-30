module Dashboard
  class TodayService
    def call
      today = Date.current
      earnings_today = Earning.where(date: today)
      expenses_today = Expense.where(date: today)

      return nil if earnings_today.none? && expenses_today.none?

      earnings_sum = earnings_today.sum(:amount)
      expenses_sum = expenses_today.sum(:amount)

      {
        earnings: earnings_sum,
        expenses: expenses_sum,
        net: earnings_sum - expenses_sum,
        trips_count: earnings_today.sum(:trips_count)
      }
    end
  end
end

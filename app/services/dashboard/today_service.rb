module Dashboard
  class TodayService
    def initialize(user: Current.user, date: Date.current)
      @user = user
      @date = date
    end

    def call
      earnings_today = @user.earnings.where(date: @date)
      expenses_today = @user.expenses.where(date: @date)

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

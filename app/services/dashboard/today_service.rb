module Dashboard
  class TodayService
    def initialize(user: Current.user, date: Date.current)
      @user = user
      @date = date
    end

    def call
      earnings_count, earnings_sum, trips_sum = @user.earnings.where(date: @date)
        .pick(Arel.sql('COUNT(*), SUM(amount), SUM(trips_count)'))
      expenses_count, expenses_sum = @user.expenses.where(date: @date)
        .pick(Arel.sql('COUNT(*), SUM(amount)'))

      return nil if earnings_count.zero? && expenses_count.zero?

      earnings_total = earnings_sum || 0
      expenses_total = expenses_sum || 0

      {
        earnings:    earnings_total,
        expenses:    expenses_total,
        net:         earnings_total - expenses_total,
        trips_count: trips_sum.to_i
      }
    end
  end
end

module Dashboard
  class TodayService
    def initialize(user: Current.user, date: Date.current)
      @user = user
      @date = date
    end

    def call
      earnings_sql = @user.earnings.where(date: @date)
        .select(Arel.sql('COUNT(*) AS earnings_count, SUM(amount) AS earnings_sum, SUM(trips_count) AS trips_sum')).to_sql
      expenses_sql = @user.expenses.where(date: @date)
        .select(Arel.sql('COUNT(*) AS expenses_count, SUM(amount) AS expenses_sum')).to_sql

      earnings_count, earnings_sum, trips_sum, expenses_count, expenses_sum = Earning
        .from("(#{earnings_sql}) AS earned CROSS JOIN (#{expenses_sql}) AS spent")
        .pick(Arel.sql('earnings_count, earnings_sum, trips_sum, expenses_count, expenses_sum'))

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

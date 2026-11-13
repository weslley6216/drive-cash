module Dashboard
  class LastMonthWithData
    def self.fetch(user:, before:)
      union_sql = [
        user.earnings.where(date: ...before).select(:date),
        user.expenses.paid_only.where(date: ...before).select(:date)
      ].map(&:to_sql).join(' UNION ')

      date = Earning.from("(#{union_sql}) AS dates").pick(Arel.sql('MAX(dates.date)'))

      date&.beginning_of_month
    end
  end
end

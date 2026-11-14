module Dashboard
  class EntryPeriods
    def self.relation(user:)
      union_sql = [user.earnings, user.expenses]
        .map { |scope| scope.select(Arel.sql('EXTRACT(YEAR FROM date)::int AS year, EXTRACT(MONTH FROM date)::int AS month')).to_sql }
        .join(' UNION ')

      Earning.from("(#{union_sql}) AS periods")
    end
  end
end

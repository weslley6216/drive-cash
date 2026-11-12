module Dashboard
  class AvailableYears
    def self.fetch(user: Current.user, date: Date.current)
      union_sql = [user.earnings, user.expenses]
        .map { |scope| scope.select(Arel.sql('EXTRACT(YEAR FROM date)::int AS year')).to_sql }
        .join(' UNION ')

      years = Earning.from("(#{union_sql}) AS years").pluck(Arel.sql('years.year'))

      (years + [date.year]).uniq.sort.reverse
    end
  end
end

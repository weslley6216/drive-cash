module Dashboard
  class AvailableYears
    def self.fetch(user: Current.user)
      earning_years = user.earnings.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::int'))
      expense_years = user.expenses.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::int'))

      years = (earning_years + expense_years).uniq.sort.reverse

      (years + [Date.current.year]).uniq.sort.reverse
    end
  end
end

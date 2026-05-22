module Dashboard
  class AvailableYears
    CACHE_KEY = 'dashboard/available_years'

    def self.fetch
      Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
        earning_years = Earning.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::int'))
        expense_years = Expense.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::int'))

        years = (earning_years + expense_years).uniq.sort.reverse

        (years + [Date.current.year]).uniq.sort.reverse
      end
    end
  end
end

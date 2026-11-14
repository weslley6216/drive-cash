module Dashboard
  class AvailableYears
    def self.fetch(user: Current.user, date: Date.current)
      years = EntryPeriods.relation(user: user).distinct.pluck(Arel.sql('periods.year'))

      (years + [date.year]).uniq.sort.reverse
    end
  end
end

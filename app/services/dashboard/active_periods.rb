module Dashboard
  class ActivePeriods
    def self.fetch(user:, date: Date.current)
      pairs = EntryPeriods.relation(user: user).distinct.pluck(Arel.sql('periods.year'), Arel.sql('periods.month'))
      pairs << [date.year, date.month]

      cutoff = date.beginning_of_month
      pairs = pairs.reject { |year, month| Date.new(year, month, 1) > cutoff }

      pairs.uniq.group_by(&:first).transform_values { |group| group.map(&:last).sort }.sort.to_h
    end
  end
end

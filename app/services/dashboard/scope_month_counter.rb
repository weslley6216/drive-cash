module Dashboard
  module ScopeMonthCounter
    def self.count_for(scope)
      scope
        .distinct
        .count(Arel.sql("TO_CHAR(date, 'YYYY-MM')"))
        .clamp(1, Float::INFINITY)
    end
  end
end

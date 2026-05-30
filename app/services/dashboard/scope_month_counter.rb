module Dashboard
  module ScopeMonthCounter
    def self.count_for(scope)
      scope
        .pluck(Arel.sql("DISTINCT TO_CHAR(date, 'YYYY-MM')"))
        .count
        .clamp(1, Float::INFINITY)
    end

    private

    def distinct_months_count
      @distinct_months_count ||= ScopeMonthCounter.count_for(scope)
    end
  end
end

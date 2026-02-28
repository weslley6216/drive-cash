module Dashboard
  module ScopeMonthCounter
    private

    def distinct_months_count
      @distinct_months_count ||= scope
        .pluck(Arel.sql("DISTINCT TO_CHAR(date, 'YYYY-MM')"))
        .count
        .clamp(1, Float::INFINITY)
    end
  end
end

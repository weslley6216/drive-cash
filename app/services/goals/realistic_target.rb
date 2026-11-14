module Goals
  class RealisticTarget
    MONTHS = 3
    ROUNDING_STEP = 100

    def self.call(user:, date:)
      months = MONTHS.downto(1).map { |months_ago| (date.beginning_of_month - months_ago.months).all_month }
      totals = DailyTotals.for(user: user, range: months.first.first..months.last.last)

      return nil unless months.all? { |month| totals.active_in?(month) }

      average = months.sum { |month| totals.profit_in(month) } / MONTHS
      rounded = (average / ROUNDING_STEP).floor * ROUNDING_STEP

      rounded.positive? ? rounded : nil
    end
  end
end

module Dashboard
  class MetricsCalculator
    HOURS_PER_DAY = 8

    def self.from_stats(stats)
      new(
        profit:   stats[:profit],
        trips:    stats[:trips],
        days:     stats[:days],
        earnings: stats[:earnings]
      )
    end

    def initialize(profit:, trips:, days:, earnings:)
      @profit   = profit.to_f
      @trips    = trips.to_i
      @days     = days.to_i
      @earnings = earnings.to_f
    end

    def per_trip
      return 0 if @trips.zero?

      (@profit / @trips).round(2)
    end

    def per_hour
      return 0 if @days.zero?

      (@profit / (@days * HOURS_PER_DAY)).round(2)
    end

    def margin
      return 0 if @earnings.zero?

      ((@profit / @earnings) * 100).round(1)
    end
  end
end

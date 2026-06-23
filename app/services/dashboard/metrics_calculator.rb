module Dashboard
  class MetricsCalculator
    def self.from_stats(stats)
      new(profit: stats[:profit], trips: stats[:trips], earnings: stats[:earnings])
    end

    def initialize(profit:, trips:, earnings:)
      @profit = profit.to_f
      @trips = trips.to_i
      @earnings = earnings.to_f
    end

    def per_trip
      return 0 if @trips.zero?

      (@profit / @trips).round(2)
    end

    def per_km(km)
      return nil if km.nil? || km.zero?

      (@profit / km).round(2)
    end

    def margin
      return 0 if @earnings.zero?

      ((@profit / @earnings) * 100).round(1)
    end
  end
end

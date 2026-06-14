module Dashboard
  class DerivedMetrics
    def initialize(earnings:, expenses:, profit:, days:, trips:, months_count:, year:, month:)
      @earnings = earnings
      @expenses = expenses
      @profit = profit
      @days = days
      @trips = trips
      @months_count = months_count
      @year = year
      @month = month
    end

    def call
      {
        expenses_percent: expenses_percent,
        profit_per_day:   profit_per_day,
        days_avg_month:   days_avg_month,
        days_avg_week:    days_avg_week,
        trips_avg_month:  trips_avg_month,
        trips_avg_day:    trips_avg_day
      }
    end

    private

    def expenses_percent
      return 0 if @earnings.zero?

      (@expenses / @earnings * 100).round(1)
    end

    def profit_per_day
      return 0 if @days.zero?

      @profit / @days
    end

    def days_avg_month
      return 0 if @months_count.zero?

      (@days.to_f / @months_count).round(1)
    end

    def days_avg_week
      return 0 if @month.blank? || @days.zero?

      days_in_month = Time.days_in_month(@month.to_i, @year.to_i)
      weeks_count = days_in_month / 7.0

      (@days / weeks_count).round
    end

    def trips_avg_month
      return 0 if @months_count.zero?

      (@trips.to_f / @months_count).round
    end

    def trips_avg_day
      return 0 if @days.zero?

      (@trips.to_f / @days).round
    end
  end
end

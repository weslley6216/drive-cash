module Dashboard
  class EarningsCalculator
    def initialize(earning_days)
      @earning_days = earning_days
    end

    def call
      {
        total:         total_earnings,
        avg_per_month: avg_per_month,
        avg_per_day:   avg_per_day,
        days_count:    days_count,
        trips_count:   total_trips,
        months_count:  months_count
      }
    end

    private

    attr_reader :earning_days

    def total_earnings
      @total_earnings ||= earning_days.values.sum(0) { |earning_day| earning_day.amount }
    end

    def days_count
      @days_count ||= earning_days.size
    end

    def months_count
      @months_count ||= [earning_days.keys.map(&:month).uniq.size, 1].max
    end

    def avg_per_month
      return 0 if months_count.zero?
      total_earnings / months_count
    end

    def avg_per_day
      return 0 if days_count.zero?
      total_earnings / days_count
    end

    def total_trips
      @total_trips ||= earning_days.values.sum(0) { |earning_day| earning_day.trips }
    end
  end
end

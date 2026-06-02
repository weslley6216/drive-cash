module Dashboard
  class InsightsService
    HOURS_PER_DAY = 8

    def initialize(year:, month: nil)
      @year = year
      @month = month
    end

    def call
      {
        metrics: metrics,
        monthly_bars: [],
        categories: [],
        platforms: [],
        insights: []
      }
    end

    private

    attr_reader :year, :month

    def current_stats
      @current_stats ||= Dashboard::StatsService.new(year: year, month: month).call
    end

    def previous_stats
      @previous_stats ||= Dashboard::StatsService.new(year: previous_year, month: previous_month).call
    end

    def previous_year
      return year - 1 if month.nil?
      month == 1 ? year - 1 : year
    end

    def previous_month
      return nil if month.nil?
      month == 1 ? 12 : month - 1
    end

    def metrics
      {
        per_day: current_stats[:profit_per_day],
        per_trip: per_trip(current_stats),
        per_hour: per_hour(current_stats),
        margin: margin(current_stats),
        change_pct: {
          per_day:  pct_change(current_stats[:profit_per_day], previous_stats[:profit_per_day]),
          per_trip: pct_change(per_trip(current_stats), per_trip(previous_stats)),
          per_hour: pct_change(per_hour(current_stats), per_hour(previous_stats)),
          margin:   pct_change(margin(current_stats), margin(previous_stats))
        }
      }
    end

    def per_trip(stats)
      trips = stats[:trips].to_i
      return 0 if trips.zero?

      (stats[:profit].to_f / trips).round(2)
    end

    def per_hour(stats)
      days = stats[:days].to_i
      return 0 if days.zero?

      (stats[:profit].to_f / (days * HOURS_PER_DAY)).round(2)
    end

    def margin(stats)
      earnings = stats[:earnings].to_f
      return 0 if earnings.zero?

      ((stats[:profit].to_f / earnings) * 100).round(1)
    end

    def pct_change(current_value, previous_value)
      current_float  = current_value.to_f
      previous_float = previous_value.to_f
      return nil if previous_float.zero?

      ((current_float - previous_float) / previous_float.abs * 100).round(1)
    end
  end
end

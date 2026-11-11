module Dashboard
  class MetricsSeries
    MIN_POINTS = 3

    def initialize(user:, year:, month: nil)
      @user = user
      @year = year
      @month = month
    end

    def call
      series = { per_day: [], per_trip: [], per_km: [], margin: [] }

      monthly_rows.each do |month, earnings, trips, days|
        next if @month && month > @month

        profit = earnings.to_f - expenses_by_month[month].to_f
        calculator = MetricsCalculator.new(profit: profit, trips: trips, earnings: earnings)

        series[:per_day] << { month: month, value: per_day(profit, days) }
        series[:per_trip] << { month: month, value: calculator.per_trip }
        series[:margin] << { month: month, value: calculator.margin }

        per_km = calculator.per_km(km_by_month[month])
        series[:per_km] << { month: month, value: per_km } unless per_km.nil?
      end

      series.transform_values { |points| { points: points, best: points.max_by { |point| point[:value] } } }
    end

    private

    def monthly_rows
      @user.earnings.in_period(@year)
        .group(Arel.sql('EXTRACT(MONTH FROM date)::int'))
        .pluck(Arel.sql('EXTRACT(MONTH FROM date)::int, SUM(amount), SUM(trips_count), COUNT(DISTINCT date)'))
        .sort_by(&:first)
    end

    def expenses_by_month
      @expenses_by_month ||= @user.expenses.paid_in_period(@year)
        .group(Arel.sql('EXTRACT(MONTH FROM date)::int')).sum(:amount)
    end

    def km_by_month
      @km_by_month ||= KmDriven.new(user: @user, year: @year).monthly
    end

    def per_day(profit, days)
      return 0 if days.to_i.zero?

      (profit / days).round(2)
    end
  end
end

module Ai
  module Readers
    class Summary
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i.presence
        stats = Dashboard::StatsService.new(year: year, month: month, user: @user).metrics
        calculator = Dashboard::MetricsCalculator.from_stats(stats)
        km = Dashboard::KmDriven.new(user: @user, year: year, month: month).call

        {
          profit:   stats[:profit].to_f,
          earnings: stats[:earnings].to_f,
          expenses: stats[:expenses].to_f,
          per_km:   calculator.per_km(km),
          per_trip: calculator.per_trip,
          margin:   calculator.margin
        }
      end
    end
  end
end

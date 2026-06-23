module Ai
  module Readers
    class PerTrip
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i.presence
        stats = Dashboard::StatsService.new(year: year, month: month, user: @user).metrics

        Dashboard::MetricsCalculator.from_stats(stats).per_trip
      end
    end
  end
end

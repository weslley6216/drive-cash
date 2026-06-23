module Ai
  module Readers
    class PerKm
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i.presence
        stats = Dashboard::StatsService.new(year: year, month: month, user: @user).metrics
        km = Dashboard::KmDriven.new(user: @user, year: year, month: month).call

        Dashboard::MetricsCalculator.from_stats(stats).per_km(km)
      end
    end
  end
end

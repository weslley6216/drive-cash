module Ai
  module Readers
    class BestMonth
      def initialize(params, user:)
        @user = user
      end

      def call
        years = Dashboard::AvailableYears.fetch(user: @user)
        return nil if years.empty?

        results = years.flat_map do |year|
          (1..12).filter_map do |month|
            stats = Dashboard::StatsService.new(year: year, month: month, user: @user).metrics
            next if stats[:earnings].zero? && stats[:expenses].zero?

            { year: year, month: month, profit: stats[:profit].to_f }
          end
        end

        results.max_by { |result| result[:profit] }
      end
    end
  end
end

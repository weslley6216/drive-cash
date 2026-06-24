module Ai
  module Readers
    class CategorySpike
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i.presence
        prev_year = (month == 1 ? year - 1 : year) if month
        prev_month = (month == 1 ? 12 : month - 1) if month

        current_stats = Dashboard::StatsService.new(year: year, month: month, user: @user).metrics
        previous_stats = Dashboard::StatsService.new(year: prev_year || year - 1, month: prev_month, user: @user).metrics
        categories = Dashboard::CategoryBreakdownService.new(year: year, month: month, limit: 7, user: @user).call

        context = Dashboard::Insights::Context.new(
          user: @user, year: year, month: month,
          previous_year: prev_year || year - 1, previous_month: prev_month,
          current_stats: current_stats, previous_stats: previous_stats,
          categories: categories, platforms: []
        )

        Dashboard::Insights::CategorySpike.new(context).call&.dig(:payload)
      end
    end
  end
end

module Ai
  module Readers
    class WorstPlatform
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i.presence
        platforms = Dashboard::PlatformBreakdownService.new(year: year, month: month, limit: 5, user: @user).call

        context = Dashboard::Insights::Context.new(
          user: @user, year: year, month: month,
          previous_year: nil, previous_month: nil,
          current_stats: {}, previous_stats: {},
          categories: [], platforms: platforms
        )

        Dashboard::Insights::WorstPlatform.new(context).call&.dig(:payload)
      end
    end
  end
end

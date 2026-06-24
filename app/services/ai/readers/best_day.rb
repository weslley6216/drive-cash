module Ai
  module Readers
    class BestDay
      def initialize(params, user:)
        @params = params
        @user = user
      end

      def call
        year = @params['year']&.to_i || Date.current.year
        month = @params['month']&.to_i || Date.current.month

        context = Dashboard::Insights::Context.new(
          user: @user, year: year, month: month,
          previous_year: nil, previous_month: nil,
          current_stats: {}, previous_stats: {},
          categories: [], platforms: []
        )

        Dashboard::Insights::BestDay.new(context).call&.dig(:payload)
      end
    end
  end
end

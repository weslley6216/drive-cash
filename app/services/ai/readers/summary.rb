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

        {
          year:          year,
          month:         month,
          profit:        stats[:profit].to_f,
          earnings:      stats[:earnings].to_f,
          expenses:      stats[:expenses].to_f,
          profit_change: month && previous_month_profit_change(year, month, stats[:profit]),
          best_day:      month && Ai::Readers::BestDay.new(@params, user: @user).call
        }
      end

      private

      def previous_month_profit_change(year, month, profit)
        previous = Date.new(year, month).prev_month
        previous_profit = Dashboard::StatsService.new(year: previous.year, month: previous.month, user: @user).metrics[:profit]
        Dashboard::PercentChange.between(profit, previous_profit)
      end
    end
  end
end

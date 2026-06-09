module Dashboard
  module Insights
    class BestDay
      def initialize(context)
        @context = context
      end

      def call
        return nil unless @context.month

        best = @context.user.earnings
                       .in_period(@context.year, @context.month)
                       .group(:date)
                       .sum(:amount)
                       .max_by { |_date, amount| amount }
        return nil if best.nil?

        date, amount = best
        {
          type: 'best_day',
          severity: 'info',
          payload: { date: date, amount: amount.to_f }
        }
      end
    end
  end
end

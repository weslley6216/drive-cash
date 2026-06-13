module Dashboard
  module Insights
    class CategorySpike
      THRESHOLD = 10.0

      def initialize(context)
        @context = context
      end

      def call
        current_top = @context.categories.first
        return nil if current_top.nil?

        previous_amount = previous_amount_for(current_top[:id])
        return nil if previous_amount.zero?

        pct = ((current_top[:amount].to_f - previous_amount) / previous_amount * 100).round(1)
        return nil if pct <= THRESHOLD

        {
          type: 'category_spike',
          severity: 'warning',
          payload: {
            mode: @context.month ? :monthly : :annual,
            category: current_top[:label],
            pct: pct,
            amount: current_top[:amount].to_f,
            previous_year: @context.previous_year,
            month: @context.month,
            previous_month: @context.previous_month
          }
        }
      end

      private

      def previous_amount_for(category_id)
        return 0 unless category_id

        @context.user.expenses
                .paid_in_period(@context.previous_year, @context.previous_month)
                .where(category: category_id)
                .sum(:amount)
                .to_f
      end
    end
  end
end

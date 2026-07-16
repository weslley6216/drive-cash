module Notifications
  module Generators
    class WeeklySummary
      def initialize(context)
        @context = context
      end

      def call
        return [] unless earnings.exists?

        [{
          kind:  'weekly_summary',
          data:  {
            'week_start' => week_start,
            'profit'     => (earnings.sum(:amount) - expenses_total).to_f,
            'trips'      => earnings.sum(:trips_count)
          },
          dedup: { 'week_start' => week_start }
        }]
      end

      private

      def week
        @week ||= (@context.date - 1.week).all_week
      end

      def week_start = week.first.to_s

      def earnings
        @earnings ||= @context.user.earnings.where(date: week)
      end

      def expenses_total
        @context.user.expenses.paid_only.where(date: week).sum(:amount)
      end
    end
  end
end

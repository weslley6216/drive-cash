module Notifications
  module Generators
    class WeeklySummary
      def initialize(context)
        @context = context
      end

      def call
        return [] unless builder.days_worked.positive?

        [{
          kind:  'weekly_summary',
          data:  {
            'week_start' => week_start,
            'profit'     => builder.profit.to_f,
            'trips'      => builder.trips
          },
          dedup: { 'week_start' => week_start }
        }]
      end

      private

      def week
        @week ||= (@context.date - 1.week).all_week
      end

      def week_start = week.first.to_s

      def builder
        @builder ||= WeeklySummaries::Builder.new(user: @context.user, week: week)
      end
    end
  end
end

module Notifications
  module Generators
    class LogReminder
      HABIT_WEEKS = 4
      HABIT_MIN_DAYS = 2

      def initialize(context)
        @context = context
      end

      def call
        return [] unless habit?
        return [] if logged_yesterday?

        [{
          kind:  'log_reminder',
          data:  { 'date' => @context.date.to_s },
          dedup: { 'date' => @context.date.to_s }
        }]
      end

      private

      def yesterday = @context.date - 1

      def habit_dates
        (1..HABIT_WEEKS).map { |weeks| yesterday - weeks.weeks }
      end

      def habit?
        @context.user.earnings.where(date: habit_dates).distinct.count(:date) >= HABIT_MIN_DAYS
      end

      def logged_yesterday?
        @context.user.earnings.where(date: yesterday).exists?
      end
    end
  end
end

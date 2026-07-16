module Notifications
  module Generators
    class LogReminder
      ACTIVE_WINDOW_DAYS = 7

      def initialize(context)
        @context = context
      end

      def call
        return [] unless active_driver?
        return [] if logged_yesterday?

        [{
          kind:  'log_reminder',
          data:  { 'date' => @context.date.to_s },
          dedup: { 'date' => @context.date.to_s }
        }]
      end

      private

      def yesterday = @context.date - 1

      def active_driver?
        @context.user.earnings.where(date: (yesterday - ACTIVE_WINDOW_DAYS)...yesterday).exists?
      end

      def logged_yesterday?
        @context.user.earnings.where(date: yesterday).exists?
      end
    end
  end
end

module Goals
  module Outcomes
    class Base
      BestDay = Data.define(:date, :value)

      def initialize(goal:, totals:, date:)
        @goal = goal
        @totals = totals
        @date = date
      end

      private

      def period
        @goal.period_start..@goal.period_end
      end

      def achieved
        @totals.metric_for(@goal)
      end

      def worked_days
        @totals.worked_days_in(period)
      end

      def per_day
        return 0 if worked_days.zero?

        achieved / worked_days
      end

      def best_day
        day = period.max_by { |candidate| @totals.metric_on(@goal, candidate) }
        BestDay.new(date: day, value: @totals.metric_on(@goal, day))
      end

      def next_period
        candidate = @goal.next_period
        return nil if candidate.last < @date

        candidate
      end

      def next_goal
        return nil unless next_period

        @goal.user.goals.find_by(kind: @goal.kind, period_start: next_period.first)
      end
    end
  end
end

module Goals
  module Outcomes
    class Hit < Base
      Result = Data.define(:goal, :target, :achieved, :percent, :surplus, :hit_on, :days_before_end,
                           :worked_days, :per_day, :best_day, :streak, :next_period, :next_goal, :suggestion) do
        def state = 'hit'

        def celebration? = true
      end

      def self.applies?(goal:, achieved:, date:)
        achieved >= goal.target_amount
      end

      def call
        hit_day = hit_on

        Result.new(
          goal:            @goal,
          target:          @goal.target_amount,
          achieved:        achieved,
          percent:         achieved * 100 / @goal.target_amount,
          surplus:         achieved - @goal.target_amount,
          hit_on:          hit_day,
          days_before_end: (@goal.period_end - hit_day).to_i,
          worked_days:     worked_days,
          per_day:         per_day,
          best_day:        best_day,
          streak:          Goals::Streak.new(goal: @goal).count,
          next_period:     next_period,
          next_goal:       next_goal,
          suggestion:      Goals::NextTarget.new(result: achieved).amount
        )
      end

      private

      def hit_on
        running = 0
        period.find { |day| (running += @totals.metric_on(@goal, day)) >= @goal.target_amount }
      end
    end
  end
end

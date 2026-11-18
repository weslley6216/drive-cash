module Goals
  module Outcomes
    class Missed < Base
      Result = Data.define(:goal, :target, :achieved, :percent, :shortfall, :near, :worked_days, :per_day,
                           :best_day, :track_record, :next_period, :next_goal, :adjusted_target,
                           :work_days, :per_work_day) do
        def state = 'missed'

        def celebration? = false
      end

      def self.applies?(goal:, achieved:, date:)
        achieved < goal.target_amount && goal.period_end < date
      end

      def call
        shortfall = Goals::Shortfall.new(target: @goal.target_amount, achieved: achieved)
        recent = Goals::RecentPeriods.new(goal: @goal, totals: @totals)
        days = work_days(recent.average_worked_days)

        Result.new(
          goal:            @goal,
          target:          @goal.target_amount,
          achieved:        achieved,
          percent:         shortfall.percent,
          shortfall:       shortfall.amount,
          near:            shortfall.near?,
          worked_days:     worked_days,
          per_day:         per_day,
          best_day:        best_day,
          track_record:    Goals::TrackRecord.new(goal: @goal).call,
          next_period:     next_period,
          next_goal:       next_goal,
          adjusted_target: Goals::AdjustedTarget.new(average: recent.average_result, target: @goal.target_amount).amount,
          work_days:       days,
          per_work_day:    @goal.target_amount / days
        )
      end

      private

      def work_days(average)
        return @goal.next_period.count unless average

        average.round.clamp(1, @goal.next_period.count)
      end
    end
  end
end

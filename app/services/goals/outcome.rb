module Goals
  class Outcome
    Result = Data.define(:goal, :target, :achieved, :percent, :surplus, :hit_on, :days_before_end,
                         :worked_days, :per_day, :best_day, :streak, :next_period, :next_goal, :suggestion)
    BestDay = Data.define(:date, :value)

    def initialize(goal:, date: Date.current)
      @goal = goal
      @date = date
    end

    def call
      totals = Goals::DailyTotals.for(user: @goal.user, range: period)
      achieved = totals.metric_for(@goal)
      return nil if achieved < @goal.target_amount

      hit_day = hit_on(totals)
      worked_days = totals.worked_days_in(period)

      Result.new(
        goal:            @goal,
        target:          @goal.target_amount,
        achieved:        achieved,
        percent:         achieved * 100 / @goal.target_amount,
        surplus:         achieved - @goal.target_amount,
        hit_on:          hit_day,
        days_before_end: (@goal.period_end - hit_day).to_i,
        worked_days:     worked_days,
        per_day:         achieved / worked_days,
        best_day:        best_day(totals),
        streak:          Goals::Streak.new(goal: @goal).count,
        next_period:     next_period,
        next_goal:       next_goal,
        suggestion:      Goals::NextTarget.new(result: achieved).amount
      )
    end

    private

    def period
      @goal.period_start..@goal.period_end
    end

    def hit_on(totals)
      running = 0
      period.find { |day| (running += totals.metric_on(@goal, day)) >= @goal.target_amount }
    end

    def best_day(totals)
      day = period.max_by { |candidate| totals.metric_on(@goal, candidate) }
      BestDay.new(date: day, value: totals.metric_on(@goal, day))
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

module Goals
  class RecentPeriods
    COUNT = 4

    def self.span(goal)
      periods_of(goal).last.first..goal.period_end
    end

    def self.periods_of(goal)
      collected = [goal.period_start..goal.period_end]
      (COUNT - 1).times { collected << Goal.period_for(goal.kind, collected.last.first - 1) }
      collected
    end

    def initialize(goal:, totals:)
      @goal = goal
      @totals = totals
    end

    def average_result
      average(active_periods.map { |period| @totals.metric_in(@goal, period) })
    end

    def average_worked_days
      average(active_periods.map { |period| @totals.worked_days_in(period) })
    end

    private

    def active_periods
      @active_periods ||= self.class.periods_of(@goal).select { |period| @totals.active_in?(period) }
    end

    def average(values)
      return nil if values.empty?

      values.sum.fdiv(values.size)
    end
  end
end

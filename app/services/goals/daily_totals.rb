module Goals
  class DailyTotals
    def self.for(user:, range:)
      earnings_by_day = user.earnings.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)
      expenses_by_day = user.expenses.paid_only.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)
      new(earnings_by_day, expenses_by_day)
    end

    def self.for_goals(user:, goals:)
      return new({}, {}) if goals.empty?

      range = goals.min_by(&:period_start).period_start..goals.max_by(&:period_end).period_end
      self.for(user: user, range: range)
    end

    def initialize(earnings_by_day, expenses_by_day)
      @earnings_by_day = earnings_by_day
      @expenses_by_day = expenses_by_day
    end

    def metric_for(goal)
      period = goal.period_start..goal.period_end
      earned = period.sum { |day| @earnings_by_day.fetch(day, 0) }
      spent = period.sum { |day| @expenses_by_day.fetch(day, 0) }
      MetricValue.of(goal, earned: earned, spent: spent)
    end

    def metric_on(goal, day)
      earned = @earnings_by_day.fetch(day, 0)
      spent = @expenses_by_day.fetch(day, 0)
      MetricValue.of(goal, earned: earned, spent: spent)
    end
  end
end

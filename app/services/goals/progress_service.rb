module Goals
  class ProgressService
    MIN_DAYS_FOR_PROJECTION = 3

    def initialize(user:, date: Date.current)
      @user = user
      @date = date
    end

    def call
      {
        weekly:       progress_for('weekly'),
        monthly:      monthly,
        annual:       progress_for('annual'),
        achievements: AchievementsService.new(user: @user, date: @date).call
      }
    end

    def monthly
      progress_for('monthly')
    end

    def past_goals(kind, limit: 12)
      goals = @user.goals.for_kind(kind).where('period_end < ?', @date)
        .order(period_end: :desc).limit(limit).to_a
      return [] if goals.empty?

      totals = DailyTotals.for_goals(user: @user, goals: goals)

      goals.map do |goal|
        current = totals.metric_for(goal)
        base_progress(goal, current).merge(achieved: current >= goal.target_amount)
      end
    end

    private

    def progress_for(kind)
      goal = @user.goals.for_kind(kind).active_at(@date).first
      return nil unless goal

      base = base_progress(goal, compute_metric_for_period(goal))
      goal.kind_weekly? ? base.merge(days: days_breakdown(goal)) : base.merge(projection_for(goal, base[:current]))
    end

    def base_progress(goal, current)
      target = goal.target_amount

      {
        goal:    goal,
        current: current,
        target:  target,
        percent: target.zero? ? 0 : (current / target * 100)
      }
    end

    def projection_for(goal, current)
      total_days = (goal.period_end - goal.period_start).to_i + 1
      days_elapsed = [(@date - goal.period_start).to_i + 1, 1].max
      days_remaining = [(goal.period_end - @date).to_i + 1, 0].max
      target = goal.target_amount
      reached = current >= target

      {
        projection:        projection_value(current, total_days, days_elapsed, reached),
        on_track:          reached || (current * (total_days.to_f / days_elapsed) >= target),
        reached:           reached,
        ended:             goal.ended?,
        tracking:          !reached && days_elapsed < MIN_DAYS_FOR_PROJECTION,
        surplus:           reached ? current - target : 0,
        daily_pace:        days_elapsed.zero? ? 0 : current / days_elapsed,
        remaining_per_day: remaining_per_day(target, current, days_remaining, reached),
        days_remaining:    days_remaining
      }
    end

    def projection_value(current, total_days, days_elapsed, reached)
      return current if reached
      return nil if days_elapsed < MIN_DAYS_FOR_PROJECTION

      current * (total_days.to_f / days_elapsed)
    end

    def remaining_per_day(target, current, days_remaining, reached)
      return 0 if reached || days_remaining.zero?

      [(target - current) / days_remaining, 0].max
    end

    def compute_metric_for_period(goal)
      earnings = @user.earnings.where(date: goal.period_start..goal.period_end).sum(:amount)
      expenses = @user.expenses.paid_only.where(date: goal.period_start..goal.period_end).sum(:amount)
      MetricValue.of(goal, earned: earnings, spent: expenses)
    end

    def days_breakdown(goal)
      range = goal.period_start..goal.period_end
      totals = DailyTotals.for(user: @user, range: range)

      range.map do |day|
        { date: day, today: day == @date, done: day < @date, value: totals.metric_on(goal, day) }
      end
    end
  end
end

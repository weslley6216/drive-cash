module Goals
  class ProgressService
    def initialize(user:, date: Date.current)
      @user = user
      @date = date
    end

    def call
      {
        weekly:       progress_for('weekly'),
        monthly:      progress_for('monthly'),
        annual:       progress_for('annual'),
        achievements: AchievementsService.new(user: @user, date: @date).call
      }
    end

    private

    def progress_for(kind)
      goal = @user.goals.for_kind(kind).active_at(@date).first
      return nil unless goal

      base = base_progress(goal)
      goal.kind_weekly? ? base.merge(days: days_breakdown(goal)) : base.merge(projection_for(goal, base[:current]))
    end

    def base_progress(goal)
      current = compute_metric_for_period(goal)
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
      days_remaining = [(goal.period_end - @date).to_i, 0].max
      target = goal.target_amount
      projection = current * (total_days.to_f / days_elapsed)

      {
        projection:        projection,
        on_track:          projection >= target,
        remaining_per_day: days_remaining.zero? ? 0 : (target - current) / days_remaining,
        days_remaining:    days_remaining
      }
    end

    def compute_metric_for_period(goal)
      earnings = @user.earnings.where(date: goal.period_start..goal.period_end).sum(:amount)
      expenses = @user.expenses.where(date: goal.period_start..goal.period_end).sum(:amount)
      goal.metric_profit? ? earnings - expenses : earnings
    end

    def days_breakdown(goal)
      range = goal.period_start..goal.period_end
      earnings_by_day = @user.earnings.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)
      expenses_by_day = @user.expenses.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)

      range.map do |day|
        earned = earnings_by_day.fetch(day, 0)
        spent  = expenses_by_day.fetch(day, 0)
        value  = goal.metric_profit? ? earned - spent : earned
        { date: day, today: day == @date, done: day < @date, value: value }
      end
    end
  end
end

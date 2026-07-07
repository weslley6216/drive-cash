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

      earnings_by_day, expenses_by_day = daily_totals(goals)

      goals.map do |goal|
        current = bucketed_metric(goal, earnings_by_day, expenses_by_day)
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
        ended:             @date >= goal.period_end,
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
      metric_value(goal, earnings, expenses)
    end

    def metric_value(goal, earned, spent)
      goal.metric_profit? ? earned - spent : earned
    end

    def days_breakdown(goal)
      range = goal.period_start..goal.period_end
      earnings_by_day, expenses_by_day = grouped_by_day(range)

      range.map do |day|
        earned = earnings_by_day.fetch(day, 0)
        spent = expenses_by_day.fetch(day, 0)
        { date: day, today: day == @date, done: day < @date, value: metric_value(goal, earned, spent) }
      end
    end

    def grouped_by_day(range)
      earnings_by_day = @user.earnings.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)
      expenses_by_day = @user.expenses.paid_only.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)
      [earnings_by_day, expenses_by_day]
    end

    def daily_totals(goals)
      range = goals.min_by(&:period_start).period_start..goals.max_by(&:period_end).period_end
      grouped_by_day(range)
    end

    def bucketed_metric(goal, earnings_by_day, expenses_by_day)
      period = goal.period_start..goal.period_end
      earned = period.sum { |day| earnings_by_day.fetch(day, 0) }
      spent = period.sum { |day| expenses_by_day.fetch(day, 0) }
      metric_value(goal, earned, spent)
    end
  end
end

module Goals
  class ProgressService
    def initialize(user:, date: Date.current)
      @user = user
      @date = date
    end

    def call
      {
        weekly: progress_for('weekly'),
        monthly: progress_for('monthly'),
        annual: progress_for('annual'),
        achievements: achievements
      }
    end

    private

    def progress_for(kind)
      goal = @user.goals.for_kind(kind).active_at(@date).first
      return nil unless goal

      current = compute_metric_for_period(goal)
      total_days = (goal.period_end - goal.period_start).to_i + 1
      days_elapsed = [(@date - goal.period_start).to_i + 1, 1].max
      days_remaining = [(goal.period_end - @date).to_i, 0].max
      target = goal.target_amount
      percent = target.zero? ? 0 : (current / target * 100)

      base = { goal: goal, current: current, target: target, percent: percent }

      if kind == 'weekly'
        base.merge(days: days_breakdown(goal))
      else
        projection = current * (total_days.to_f / days_elapsed)
        remaining_per_day = days_remaining.zero? ? 0 : (target - current) / days_remaining
        base.merge(
          projection: projection,
          on_track: projection >= target,
          remaining_per_day: remaining_per_day,
          days_remaining: days_remaining
        )
      end
    end

    def compute_metric_for_period(goal)
      earnings = @user.earnings.where(date: goal.period_start..goal.period_end).sum(:amount)
      expenses = @user.expenses.where(date: goal.period_start..goal.period_end).sum(:amount)
      goal.metric == 'profit' ? earnings - expenses : earnings
    end

    def days_breakdown(goal)
      (goal.period_start..goal.period_end).map do |day|
        earnings = @user.earnings.where(date: day).sum(:amount)
        expenses = @user.expenses.where(date: day).sum(:amount)
        value = goal.metric == 'profit' ? earnings - expenses : earnings
        { date: day, today: day == @date, done: day < @date, value: value }
      end
    end

    def achievements
      badges = []
      badges << streak_badge if streak_7d?
      best = best_day_in_month
      badges << best if best
      badges
    end

    def streak_7d?
      last_seven_days = (0..6).map { |offset| @date - offset }
      earning_days = @user.earnings.where(date: last_seven_days).distinct.pluck(:date)
      (last_seven_days - earning_days).empty?
    end

    def streak_badge
      { icon: 'flame', label: I18n.t('goals.index.achievements.streak_7d', days: 7), color: '#f97316' }
    end

    def best_day_in_month
      range = @date.beginning_of_month..@date.end_of_month
      row = @user.earnings.where(date: range).group(:date).sum(:amount).max_by { |_date, total| total }
      return nil unless row

      { icon: 'star', label: I18n.t('goals.index.achievements.best_day', value: row.last), color: '#eab308', value: row.last }
    end
  end
end

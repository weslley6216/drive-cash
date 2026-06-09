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
      range = goal.period_start..goal.period_end
      earnings_by_day = @user.earnings.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)
      expenses_by_day = @user.expenses.where(date: range).group(:date).sum(:amount).transform_keys(&:to_date)

      range.map do |day|
        earned = earnings_by_day.fetch(day, 0)
        spent  = expenses_by_day.fetch(day, 0)
        value  = goal.metric == 'profit' ? earned - spent : earned
        { date: day, today: day == @date, done: day < @date, value: value }
      end
    end

    def achievements
      badges = []
      badges << streak_badge if streak_7d?
      completed = goal_completed
      badges << completed if completed
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

    def goal_completed
      @user.goals.for_kind('monthly')
           .where('period_end < ?', @date)
           .order(period_end: :desc)
           .limit(6)
           .each do |goal|
        current = compute_metric_for_period(goal)
        next if current < goal.target_amount

        period_label = I18n.l(goal.period_start, format: '%B').capitalize
        return { icon: 'star', label: I18n.t('goals.index.achievements.goal_completed', period: period_label), color: '#a855f7' }
      end
      nil
    end

    def best_day_in_month
      range = @date.beginning_of_month..@date.end_of_month
      row = @user.earnings.where(date: range).group(:date).sum(:amount).max_by { |_date, total| total }
      return nil unless row

      formatted = format('%.2f', row.last.to_f).tr('.', ',')
      { icon: 'zap', label: I18n.t('goals.index.achievements.best_day', value: formatted), color: '#3b82f6', value: row.last }
    end
  end
end

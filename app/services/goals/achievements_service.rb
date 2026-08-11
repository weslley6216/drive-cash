module Goals
  class AchievementsService
    STREAK_DAYS = 7
    RECENT_GOALS_LIMIT = 6

    def initialize(user:, date: Date.current)
      @user = user
      @date = date
    end

    def call
      [streak_badge, goal_completed_badge, best_day_badge].compact
    end

    private

    def streak_badge
      return nil unless streak?

      { type: :streak, label: I18n.t('goals.index.achievements.streak_7d', days: STREAK_DAYS) }
    end

    def streak?
      last_days = (0...STREAK_DAYS).map { |offset| @date - offset }
      earning_days = @user.earnings.where(date: last_days).distinct.pluck(:date)
      (last_days - earning_days).empty?
    end

    def goal_completed_badge
      goals = @user.goals.for_kind('monthly')
        .where('period_end < ?', @date)
        .order(period_end: :desc)
        .limit(RECENT_GOALS_LIMIT).to_a
      return nil if goals.empty?

      totals = DailyTotals.for_goals(user: @user, goals: goals)
      goal = goals.find { |candidate| totals.metric_for(candidate) >= candidate.target_amount }
      return nil unless goal

      period_label = I18n.l(goal.period_start, format: '%B').capitalize
      { type: :goal_completed, label: I18n.t('goals.index.achievements.goal_completed', period: period_label) }
    end

    def best_day_badge
      range = @date.beginning_of_month..@date.end_of_month
      best = @user.earnings.where(date: range).group(:date).sum(:amount).max_by { |_date, total| total }
      return nil unless best

      formatted = format('%.2f', best.last.to_f).tr('.', ',')
      { type: :best_day, label: I18n.t('goals.index.achievements.best_day', value: formatted), value: best.last }
    end
  end
end

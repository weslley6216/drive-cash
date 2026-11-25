module WeeklySummaries
  class Builder
    Summary = Data.define(:week, :profit, :earnings_total, :expenses_total, :trips, :days_worked, :per_km,
                          :days, :best_day_index, :goal, :top_categories, :empty_days, :blank_week)
    TopCategory = Data.define(:key, :amount)
    Day = Data.define(:date, :profit, :earnings, :expenses, :trips, :empty, :future)
    GoalProgress = Data.define(:goal, :achieved, :percent, :hit)

    def self.for(user:, week_start:)
      week = Calendars::Week.parse(week_start)
      raise ActiveRecord::RecordNotFound if week.nil? || week.future?

      new(user: user, week: week)
    end

    def initialize(user:, week:)
      @user = user
      @week = week
    end

    def call
      Summary.new(
        week:           @week,
        profit:         profit,
        earnings_total: earnings_total,
        expenses_total: expenses_total,
        trips:          trips,
        days_worked:    days_worked,
        per_km:         per_km,
        days:           days,
        best_day_index: best_day_index,
        goal:           goal,
        top_categories: top_categories,
        empty_days:     empty_days,
        blank_week:     blank_week
      )
    end

    def profit
      @profit ||= totals.profit_in(range)
    end

    def trips
      @trips ||= earnings.sum(:trips_count)
    end

    def days_worked
      @days_worked ||= totals.worked_days_in(range)
    end

    private

    def range
      @week.range
    end

    def totals
      @totals ||= Goals::DailyTotals.for(user: @user, range: range)
    end

    def earnings_total
      @earnings_total ||= totals.earned_in(range)
    end

    def expenses_total
      @expenses_total ||= totals.spent_in(range)
    end

    def per_km
      km = Dashboard::KmDriven.new(user: @user, range: range).call
      km ? profit / km : nil
    end

    def days
      @days ||= range.map do |day|
        Day.new(
          date:     day,
          profit:   totals.profit_in(day..day),
          earnings: totals.earned_in(day..day),
          expenses: totals.spent_in(day..day),
          trips:    trips_by_day.fetch(day, 0),
          empty:    !recorded_days.include?(day),
          future:   day > Date.current
        )
      end
    end

    def trips_by_day
      @trips_by_day ||= earnings.group(:date).sum(:trips_count).transform_keys(&:to_date)
    end

    def best_day_index
      best_index = nil
      best_value = nil

      days.map(&:profit).each_with_index do |value, index|
        next unless value.positive?
        next if best_value && value <= best_value

        best_index = index
        best_value = value
      end

      best_index
    end

    def goal
      @goal ||= begin
        record = @user.goals.kind_weekly.find_by(period_start: @week.monday)
        record && goal_progress(record)
      end
    end

    def goal_progress(record)
      achieved = totals.metric_for(record)
      percent = Goals::Shortfall.new(target: record.target_amount, achieved: achieved).percent

      GoalProgress.new(goal: record, achieved: achieved, percent: percent, hit: achieved >= record.target_amount)
    end

    def top_categories
      category_order = Expense.categories.keys

      paid_expenses.group(:category).sum(:amount)
        .sort_by { |key, amount| [-amount, category_order.index(key)] }
        .first(3)
        .map { |key, amount| TopCategory.new(key: key, amount: amount) }
    end

    def recorded_days
      @recorded_days ||= @user.earnings.where(date: range).distinct.pluck(:date) |
                          @user.expenses.where(date: range).distinct.pluck(:date)
    end

    def empty_days
      days.reject(&:future).select(&:empty).map(&:date)
    end

    def blank_week
      recorded_days.empty?
    end

    def earnings
      @user.earnings.where(date: range)
    end

    def paid_expenses
      @user.expenses.paid_only.where(date: range)
    end
  end
end

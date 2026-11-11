module WeeklySummaries
  class Builder
    Summary = Data.define(:week, :profit, :trips, :days_worked, :per_km, :daily_profits, :best_day_index, :top_category)
    TopCategory = Data.define(:key, :amount)

    def self.for(user:, week_start:)
      monday = Date.iso8601(week_start).beginning_of_week
      new(user: user, week: monday..monday.end_of_week)
    rescue Date::Error
      raise ActiveRecord::RecordNotFound
    end

    def initialize(user:, week:)
      @user = user
      @week = week
    end

    def call
      Summary.new(
        week:           @week,
        profit:         profit,
        trips:          trips,
        days_worked:    days_worked,
        per_km:         per_km,
        daily_profits:  daily_profits,
        best_day_index: best_day_index,
        top_category:   top_category
      )
    end

    def profit
      @profit ||= earnings.sum(:amount) - paid_expenses.sum(:amount)
    end

    def trips
      @trips ||= earnings.sum(:trips_count)
    end

    def days_worked
      @days_worked ||= earnings.distinct.count(:date)
    end

    private

    def per_km
      km = Dashboard::KmDriven.new(user: @user, range: @week).call
      km ? profit / km : nil
    end

    def daily_profits
      @daily_profits ||= begin
        earnings_by_day = earnings.group(:date).sum(:amount)
        expenses_by_day = paid_expenses.group(:date).sum(:amount)

        @week.to_a.map { |date| earnings_by_day.fetch(date, 0) - expenses_by_day.fetch(date, 0) }
      end
    end

    def best_day_index
      best_index = nil
      best_value = nil

      daily_profits.each_with_index do |value, index|
        next unless value.positive?
        next if best_value && value <= best_value

        best_index = index
        best_value = value
      end

      best_index
    end

    def top_category
      totals = paid_expenses.group(:category).sum(:amount)
      best_key = nil
      best_amount = 0

      Expense.categories.each_key do |category|
        amount = totals[category]
        next unless amount && amount > best_amount

        best_key = category
        best_amount = amount
      end

      best_key ? TopCategory.new(key: best_key, amount: best_amount) : nil
    end

    def earnings
      @user.earnings.where(date: @week)
    end

    def paid_expenses
      @user.expenses.paid_only.where(date: @week)
    end
  end
end

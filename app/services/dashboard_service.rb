# frozen_string_literal: true

class DashboardService
  def initialize(deliveries)
    @deliveries = deliveries
  end

  def call
    {
      earnings: total_earnings,
      earnings_avg_month: total_earnings / months_count,
      expenses: total_expenses,
      expenses_percent: calculate_percent(total_expenses, total_earnings),
      profit: total_profit,
      profit_per_day: total_days.positive? ? (total_profit / total_days) : 0,
      days: total_days,
      days_avg_month: (total_days.to_f / months_count).round(1)
    }
  end

  private

  attr_reader :deliveries

  def total_earnings = @total_earnings ||= deliveries.total_earnings
  def total_expenses = @total_expenses ||= deliveries.total_expenses
  def total_profit   = @total_profit   ||= deliveries.total_profit
  def total_days     = @total_days     ||= deliveries.count
  def months_count   = @months_count   ||= deliveries.distinct_months_count

  def calculate_percent(part, total)
    return 0 if total.zero?

    (part / total * 100).round(1)
  end
end

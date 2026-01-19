# frozen_string_literal: true

class Delivery < ApplicationRecord
  validates :date, :route_value, presence: true
  validates :route_value, :fuel_cost, :maintenance_cost, :other_costs, numericality: { greater_than_or_equal_to: 0 }

  scope :chronological, -> { order(date: :asc) }
  scope :for_year, ->(year) { where('EXTRACT(YEAR FROM date) = ?', year) if year.present? }
  scope :for_month, ->(month) { where('EXTRACT(MONTH FROM date) = ?', month) if month.present? }

  def self.total_earnings
    sum(:route_value)
  end

  def self.total_expenses
    calculate(:sum, 'COALESCE(fuel_cost + maintenance_cost + other_costs, 0)')
  end

  def self.total_profit
    calculate(:sum, 'COALESCE(route_value - (fuel_cost + maintenance_cost + other_costs), 0)')
  end

  def self.distinct_months_count
    count("DISTINCT TO_CHAR(date, 'YYYY-MM')").clamp(1, Float::INFINITY)
  end

  def self.available_years
    years = pluck(Arel.sql('DISTINCT EXTRACT(YEAR FROM date)')).map(&:to_i).sort.reverse
    puts "==================#{years}==================="
    years.any? ? years : [Date.current.year]
  end

  def total_costs = fuel_cost + maintenance_cost + other_costs
  def net_profit = route_value - total_costs
end

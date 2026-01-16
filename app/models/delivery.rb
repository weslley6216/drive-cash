class Delivery < ApplicationRecord
  validates :date, presence: true
  validates :route_value, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :fuel_cost,
            :maintenance_cost,
            :other_costs,
            numericality: { greater_than_or_equal_to: 0 }

  def total_costs
    fuel_cost + maintenance_cost + other_costs
  end

  def net_profit
    route_value - total_costs
  end
end

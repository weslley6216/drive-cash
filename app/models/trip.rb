class Trip < ApplicationRecord
  has_many :earnings, dependent: :destroy
  has_many :expenses, dependent: :destroy

  attr_accessor :route_value, :fuel_cost, :maintenance_cost, :other_costs, :platform

  validates :date, presence: true
  validates :route_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_create :save_data_structure

  private

  def save_data_structure
    if route_value.to_f > 0
      earnings.build(
        date: date,
        amount: route_value,
        platform: platform.presence || 'shopee',
        notes: notes
      )
    end

    add_expense('fuel', fuel_cost)
    add_expense('maintenance', maintenance_cost)
    add_expense('other', other_costs)
  end

  def add_expense(category, amount)
    return unless amount.to_f > 0

    expenses.build(
      date: date,
      category: category,
      amount: amount,
      notes: notes
    )
  end
end

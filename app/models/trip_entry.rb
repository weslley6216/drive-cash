# app/models/trip_entry.rb
class TripEntry
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :route_value, :decimal, default: 0.0
  attribute :fuel_cost, :decimal, default: 0.0
  attribute :maintenance_cost, :decimal, default: 0.0
  attribute :other_costs, :decimal, default: 0.0
  attribute :platform, :string
  attribute :notes, :string

  validates :date, :route_value, presence: true
  validates :route_value, :fuel_cost, :maintenance_cost, :other_costs,
            numericality: { greater_than_or_equal_to: 0 }

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      create_earning!
      create_expenses!
      true
    end
  rescue ActiveRecord::RecordInvalid
    false
  end

  def persisted?
    false
  end

  def to_key
    nil
  end

  def model_name
    ActiveModel::Name.new(self, nil, "TripEntry")
  end

  private

  def create_earning!
    Earning.create!(
      date: date,
      amount: route_value,
      platform: platform.presence || 'other',
      notes: notes
    )
  end

  def create_expenses!
    expenses_to_create = []

    expenses_to_create << { category: :fuel, amount: fuel_cost } if fuel_cost > 0
    expenses_to_create << { category: :maintenance, amount: maintenance_cost } if maintenance_cost > 0
    expenses_to_create << { category: :other, amount: other_costs } if other_costs > 0

    expenses_to_create.each do |expense_data|
      Expense.create!(
        date: date,
        category: expense_data[:category],
        amount: expense_data[:amount],
        notes: notes
      )
    end
  end
end

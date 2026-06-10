class Vehicle < ApplicationRecord
  belongs_to :user
  has_many :maintenances, dependent: :destroy
  has_many :refuelings, dependent: :destroy

  validates :brand, :vehicle_model, :year, presence: true
  validates :odometer_km, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :year, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1900,
    less_than_or_equal_to: ->(_record) { Date.current.year + 1 }
  }

  def display_name
    "#{brand} #{vehicle_model} · #{year}"
  end
end

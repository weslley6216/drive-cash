class Refueling < ApplicationRecord
  belongs_to :vehicle
  belongs_to :expense, optional: true

  validates :date, :liters, :total_amount, :odometer_km, presence: true
  validates :liters, numericality: { greater_than: 0, allow_blank: true }
  validates :total_amount, numericality: { greater_than: 0, allow_blank: true }
  validates :odometer_km, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_blank: true }

  scope :chronological, -> { order(date: :desc, created_at: :desc) }
  scope :full_tank, -> { where(full_tank: true) }

  before_save :compute_price_per_liter

  private

  def compute_price_per_liter
    return if liters.to_f.zero?

    self.price_per_liter = (total_amount.to_f / liters.to_f).round(3)
  end
end

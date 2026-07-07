class Refueling < ApplicationRecord
  include MonetaryAmount
  include VendorNormalization
  monetize :total_amount, :liters

  belongs_to :vehicle
  belongs_to :expense, optional: true

  validates :date, :total_amount, presence: true
  validates :liters, numericality: { greater_than: 0, allow_blank: true }
  validates :total_amount, numericality: { greater_than: 0, allow_blank: true }
  validates :odometer_km, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_blank: true }

  scope :chronological, -> { order(date: :desc, created_at: :desc) }
  scope :full_tank, -> { where(full_tank: true) }

  before_save :compute_price_per_liter

  private

  def compute_price_per_liter
    return if liters.to_d.zero?

    self.price_per_liter = (total_amount.to_d / liters.to_d).round(3)
  end
end

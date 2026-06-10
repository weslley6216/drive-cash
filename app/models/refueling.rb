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

  def km_per_liter_to_previous
    return nil unless full_tank

    previous = self.class
                   .where(vehicle_id: vehicle_id, full_tank: true)
                   .where('date < ? OR (date = ? AND created_at < ?)', date, date, created_at || Time.current)
                   .order(date: :desc, created_at: :desc)
                   .first
    return nil unless previous

    delta_km = odometer_km - previous.odometer_km
    return nil if delta_km <= 0 || liters.to_f.zero?

    (delta_km / liters.to_f).round(2)
  end

  private

  def compute_price_per_liter
    return if liters.to_f.zero?

    self.price_per_liter = (total_amount.to_f / liters.to_f).round(3)
  end
end

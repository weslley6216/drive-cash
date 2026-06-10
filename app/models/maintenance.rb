class Maintenance < ApplicationRecord
  belongs_to :vehicle

  enum :category, {
    oil_change: 0,
    brake: 1,
    alignment: 2,
    tires: 3,
    other: 4
  }, prefix: true

  validates :name, presence: true
  validates :estimated_cost, numericality: { greater_than_or_equal_to: 0, allow_blank: true }

  scope :pending, -> { where(completed: false) }
  scope :due_soon, lambda { |odometer_km:, today:, km_threshold: 1000, day_threshold: 14|
    where(
      'due_at_km IS NOT NULL AND due_at_km - ? <= ? OR due_at_date IS NOT NULL AND due_at_date - ? <= ?',
      odometer_km, km_threshold, today, day_threshold
    )
  }

  def km_until
    return nil if due_at_km.blank?

    due_at_km - vehicle.odometer_km
  end

  def days_until(today: Date.current)
    return nil if due_at_date.blank?

    (due_at_date - today).to_i
  end

  def urgent?(km_threshold: 1000, day_threshold: 14, today: Date.current)
    km_value = km_until
    days_value = days_until(today: today)
    return false if km_value.nil? && days_value.nil?

    (km_value && km_value <= km_threshold) || (days_value && days_value <= day_threshold)
  end
end

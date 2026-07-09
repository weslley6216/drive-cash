class Maintenance < ApplicationRecord
  belongs_to :vehicle

  enum :category, {
    oil_change:    0,
    oil_filter:    1,
    air_filter:    2,
    fuel_filter:   3,
    tire_rotation: 4,
    brake_pads:    5,
    spark_plugs:   6,
    timing_belt:   7
  }, prefix: true

  CATALOG = {
    'oil_change'    => { interval_km: 5_000, estimated_cost: 280 },
    'oil_filter'    => { interval_km: 10_000, estimated_cost: 45 },
    'air_filter'    => { interval_km: 10_000, estimated_cost: 70 },
    'fuel_filter'   => { interval_km: 20_000, estimated_cost: 90 },
    'tire_rotation' => { interval_km: 10_000, estimated_cost: 60 },
    'brake_pads'    => { interval_km: 30_000, estimated_cost: 400 },
    'spark_plugs'   => { interval_km: 40_000, estimated_cost: 240 },
    'timing_belt'   => { interval_km: 60_000, estimated_cost: 900 }
  }.freeze

  validates :last_done_km, :interval_km, presence:     true,
                                         numericality: { greater_than: 0, only_integer: true }
  validates :estimated_cost, numericality: { greater_than_or_equal_to: 0, allow_blank: true }

  def self.catalog_defaults(kind)
    CATALOG.fetch(kind, {})
  end

  def progress
    (done.to_f / interval_km) * 100
  end

  def done
    vehicle.odometer_km - last_done_km
  end

  def target
    last_done_km + interval_km
  end

  def km_until
    target - vehicle.odometer_km
  end

  def apply_catalog_defaults
    defaults = self.class.catalog_defaults(category)
    self.interval_km ||= defaults[:interval_km]
    self.estimated_cost ||= defaults[:estimated_cost]
    self
  end
end

class Maintenance < ApplicationRecord
  belongs_to :vehicle

  enum :category, {
    oil_change: 0,
    oil_filter: 1,
    air_filter: 2,
    fuel_filter: 3,
    tire_rotation: 4,
    brake_pads: 5,
    spark_plugs: 6,
    timing_belt: 7
  }, prefix: true

  CATALOG = {
    'oil_change' => { interval_km: 5_000, estimated_cost: 280, icon: PhlexIcons::Lucide::Wrench },
    'oil_filter' => { interval_km: 10_000, estimated_cost: 45, icon: PhlexIcons::Lucide::Wind },
    'air_filter' => { interval_km: 10_000, estimated_cost: 70, icon: PhlexIcons::Lucide::Wind },
    'fuel_filter' => { interval_km: 20_000, estimated_cost: 90, icon: PhlexIcons::Lucide::Wind },
    'tire_rotation' => { interval_km: 10_000, estimated_cost: 60, icon: PhlexIcons::Lucide::Disc },
    'brake_pads' => { interval_km: 30_000, estimated_cost: 400, icon: PhlexIcons::Lucide::Shield },
    'spark_plugs' => { interval_km: 40_000, estimated_cost: 240, icon: PhlexIcons::Lucide::Zap },
    'timing_belt' => { interval_km: 60_000, estimated_cost: 900, icon: PhlexIcons::Lucide::Settings }
  }.freeze

  validates :last_done_km, :interval_km, presence: true,
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

  def status_key
    Vehicles::MaintenanceStatus.for(progress)
  end

  def icon_component
    CATALOG.fetch(category, CATALOG['oil_change'])[:icon]
  end

  def apply_catalog_defaults
    defaults = self.class.catalog_defaults(category)
    self.interval_km ||= defaults[:interval_km]
    self.estimated_cost ||= defaults[:estimated_cost]
    self
  end
end

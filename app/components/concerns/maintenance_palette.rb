module MaintenancePalette
  MAINTENANCE_ICONS = {
    'oil_change'    => PhlexIcons::Lucide::Wrench,
    'oil_filter'    => PhlexIcons::Lucide::Wind,
    'air_filter'    => PhlexIcons::Lucide::Wind,
    'fuel_filter'   => PhlexIcons::Lucide::Wind,
    'tire_rotation' => PhlexIcons::Lucide::Disc,
    'brake_pads'    => PhlexIcons::Lucide::Shield,
    'spark_plugs'   => PhlexIcons::Lucide::Zap,
    'timing_belt'   => PhlexIcons::Lucide::Settings
  }.freeze

  DEFAULT_ICON = PhlexIcons::Lucide::Wrench

  def maintenance_icon(category)
    MAINTENANCE_ICONS.fetch(category, DEFAULT_ICON)
  end
end

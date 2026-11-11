module MaintenancePalette
  MAINTENANCE_STATUS_STYLES = {
    overdue: { color: '#dc2626', badge_class: 'text-red-700 bg-red-100 border-red-200', tint_class: 'border-red-200 bg-red-50/60' },
    soon:    { color: '#f59e0b', badge_class: 'text-amber-700 bg-amber-100 border-amber-200', tint_class: 'border-amber-200 bg-amber-50/50' },
    ok:      { color: '#10b981', badge_class: 'text-slate-500 bg-slate-100 border-slate-200', tint_class: '' }
  }.freeze

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

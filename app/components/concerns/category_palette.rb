module CategoryPalette
  CATEGORY_META = {
    'fuel'          => { color: '#dc2626', icon: PhlexIcons::Lucide::Fuel },
    'maintenance'   => { color: '#f59e0b', icon: PhlexIcons::Lucide::Wrench },
    'car_wash'      => { color: '#8b5cf6', icon: PhlexIcons::Lucide::Sparkles },
    'toll'          => { color: '#3b82f6', icon: PhlexIcons::Lucide::Route },
    'parking'       => { color: '#6366f1', icon: PhlexIcons::Lucide::SquareParking },
    'documentation' => { color: '#0d9488', icon: PhlexIcons::Lucide::FileText },
    'insurance'     => { color: '#2563eb', icon: PhlexIcons::Lucide::ShieldCheck },
    'fine'          => { color: '#b91c1c', icon: PhlexIcons::Lucide::TriangleAlert },
    'meals'         => { color: '#10b981', icon: PhlexIcons::Lucide::Utensils },
    'phone'         => { color: '#06b6d4', icon: PhlexIcons::Lucide::Phone },
    'other'         => { color: '#64748b', icon: PhlexIcons::Lucide::Package }
  }.freeze

  DEFAULT_COLOR = '#94a3b8'
  DEFAULT_ICON = PhlexIcons::Lucide::Package

  def category_color(category)
    CATEGORY_META.dig(category, :color) || DEFAULT_COLOR
  end

  def category_icon(category)
    CATEGORY_META.dig(category, :icon) || DEFAULT_ICON
  end
end

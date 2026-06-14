module CategoryPalette
  CATEGORY_META = {
    'fuel'          => { color: '#dc2626', icon: PhlexIcons::Lucide::Fuel },
    'maintenance'   => { color: '#f97316', icon: PhlexIcons::Lucide::Wrench },
    'car_wash'      => { color: '#0ea5e9', icon: PhlexIcons::Lucide::Droplet },
    'toll'          => { color: '#a855f7', icon: PhlexIcons::Lucide::Coins },
    'parking'       => { color: '#6366f1', icon: PhlexIcons::Lucide::SquareParking },
    'documentation' => { color: '#0d9488', icon: PhlexIcons::Lucide::FileText },
    'insurance'     => { color: '#2563eb', icon: PhlexIcons::Lucide::ShieldCheck },
    'fine'          => { color: '#b91c1c', icon: PhlexIcons::Lucide::TriangleAlert },
    'meals'         => { color: '#16a34a', icon: PhlexIcons::Lucide::Utensils },
    'phone'         => { color: '#7c3aed', icon: PhlexIcons::Lucide::Smartphone }
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

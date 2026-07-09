module PlatformPalette
  PLATFORM_META = {
    'uber'          => { color: '#000000', fg: '#ffffff' },
    'nine_nine'     => { color: '#fbbf24', fg: '#000000' },
    'ifood'         => { color: '#ef4444', fg: '#ffffff' },
    'rappi'         => { color: '#dc2626', fg: '#ffffff' },
    'shopee'        => { color: '#f97316', fg: '#ffffff' },
    'amazon'        => { color: '#1e293b', fg: '#ffffff' },
    'mercado_livre' => { color: '#fef08a', fg: '#000000' },
    'other'         => { color: '#cbd5e1', fg: '#0f172a' }
  }.freeze

  DEFAULT_COLOR = '#94a3b8'
  DEFAULT_FG = '#0f172a'

  def platform_color(platform)
    PLATFORM_META.dig(platform, :color) || DEFAULT_COLOR
  end

  def platform_fg(platform)
    PLATFORM_META.dig(platform, :fg) || DEFAULT_FG
  end
end

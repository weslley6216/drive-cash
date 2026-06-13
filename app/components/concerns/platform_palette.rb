module PlatformPalette
  PLATFORM_META = {
    'amazon'        => '#ff9900',
    'ifood'         => '#ea1d2c',
    'mercado_livre' => '#ffe600',
    'nine_nine'     => '#fbbf24',
    'rappi'         => '#ff0033',
    'shopee'        => '#ee4d2d',
    'uber'          => '#000000'
  }.freeze

  DEFAULT_COLOR = '#94a3b8'

  def platform_color(platform)
    PLATFORM_META[platform] || DEFAULT_COLOR
  end
end

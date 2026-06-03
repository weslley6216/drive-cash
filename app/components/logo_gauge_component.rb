class LogoGaugeComponent < ApplicationComponent
  def initialize(size: 32, fg: '#fff', accent: '#10b981', hub: '#2563eb')
    @size   = size
    @fg     = fg
    @accent = accent
    @hub    = hub
  end

  def view_template
    svg(width: @size, height: @size, viewBox: '0 0 100 100', fill: 'none', style: 'display:block') do |svg|
      svg.path(d: 'M29.4 76.5 A32 32 0 1 1 70.6 76.5', stroke: @fg, 'stroke-width': '9', 'stroke-linecap': 'round')
      svg.path(d: 'M66 24.3 A32 32 0 0 1 70.6 76.5',  stroke: @accent, 'stroke-width': '9', 'stroke-linecap': 'round')
      svg.line(x1: '50', y1: '52', x2: '67', y2: '35', stroke: @fg, 'stroke-width': '7.5', 'stroke-linecap': 'round')
      svg.circle(cx: '50', cy: '52', r: '7.5', fill: @fg)
      svg.circle(cx: '50', cy: '52', r: '3',   fill: @hub)
    end
  end
end

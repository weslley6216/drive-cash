class HeroProfitCardComponent < ApplicationComponent
  MOBILE_CHART_WIDTH  = 320
  MOBILE_CHART_HEIGHT = 70

  DESKTOP_CHART_WIDTH  = 720
  DESKTOP_CHART_HEIGHT = 120

  MONTHS_PT = %w[Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez].freeze

  def initialize(profit:, change_percent:, profit_per_day:, days_count:, monthly_series:, year:, month: nil, daily_mode: false)
    @profit = profit
    @change_percent = change_percent
    @profit_per_day = profit_per_day
    @days_count = days_count
    @series = (monthly_series || []).map(&:to_f)
    @year = year
    @month = month
    @daily_mode = daily_mode
  end

  def view_template
    div(class: 'rounded-2xl bg-blue-50 border-2 border-blue-200 p-5 lg:p-6 relative overflow-hidden animate-slide-up') do
      header_section
      subtitle_section
      chart_section
    end
  end

  private

  def header_section
    div(class: 'flex items-start justify-between mb-1') do
      div do
        p(class: 'text-xs lg:text-sm font-medium text-blue-700 uppercase tracking-wider opacity-75') { label_text }
        p(class: 'text-3xl lg:text-5xl font-bold mt-1 lg:mt-2 tracking-tight text-blue-900 tabular-nums') do
          format_currency(@profit)
        end
      end
      change_badge if @change_percent
    end
  end

  def change_badge
    positive = @change_percent.to_f >= 0
    classes = positive ? 'bg-emerald-100 text-emerald-700 border-emerald-200' : 'bg-red-100 text-red-700 border-red-200'
    icon = positive ? PhlexIcons::Lucide::ArrowUpRight : PhlexIcons::Lucide::ArrowDownRight

    div(class: class_names('flex items-center gap-1 rounded-full px-2 py-1 lg:px-3 lg:py-1.5 text-xs lg:text-sm font-semibold border', classes)) do
      render icon.new(class: 'w-3 h-3 lg:w-3.5 lg:h-3.5')
      plain I18n.t(positive ? 'hero_profit_card_component.change_positive' : 'hero_profit_card_component.change_negative',
                   value: @change_percent.abs.to_s)
    end
  end

  def subtitle_section
    p(class: 'text-sm text-blue-700 mt-1 lg:mt-2 opacity-80') { subtitle_text }
  end

  def chart_section
    return if @series.empty? || @series.all?(&:zero?)

    div(class: 'mt-4') do
      div(class: 'lg:hidden') { mobile_chart }
      div(class: 'hidden lg:block') { desktop_chart }

      unless chart_labels.empty?
        div(class: 'flex justify-between text-[10px] lg:text-xs text-blue-700 opacity-60 mt-1 px-1') do
          chart_labels.each { |label| span { label } }
        end
      end
    end
  end

  def mobile_chart
    render_chart(width: MOBILE_CHART_WIDTH, height: MOBILE_CHART_HEIGHT,
                 gradient_id: 'profitFillMobile', last_dot_r: 4, dot_r: 2.5,
                 stroke_width: 2.5, height_class: 'h-[70px]')
  end

  def desktop_chart
    render_chart(width: DESKTOP_CHART_WIDTH, height: DESKTOP_CHART_HEIGHT,
                 gradient_id: 'profitFillDesktop', last_dot_r: 5, dot_r: 3.5,
                 stroke_width: 3.0, height_class: 'h-[120px]')
  end

  def render_chart(width:, height:, gradient_id:, last_dot_r:, dot_r:, stroke_width:, height_class:)
    pts = compute_points(width: width, height: height)
    return if pts.empty?

    svg(
      viewBox: "0 0 #{width} #{height}",
      class: "w-full #{height_class}",
      xmlns: 'http://www.w3.org/2000/svg'
    ) do |s|
      s.defs do
        s.linearGradient(id: gradient_id, x1: '0', y1: '0', x2: '0', y2: '1') do
          s.stop(offset: '0%', 'stop-color': '#3b82f6', 'stop-opacity': '0.35')
          s.stop(offset: '100%', 'stop-color': '#3b82f6', 'stop-opacity': '0')
        end
      end

      s.path(d: area_path(pts, height), fill: "url(##{gradient_id})")
      s.path(
        d: line_path(pts), fill: 'none', stroke: '#1d4ed8',
        'stroke-width': stroke_width.to_s,
        'stroke-linecap': 'round', 'stroke-linejoin': 'round'
      )
      pts.each_with_index do |(x, y), idx|
        last = idx == pts.size - 1
        s.circle(
          cx: x, cy: y, r: (last ? last_dot_r : dot_r).to_s,
          fill: last ? '#1d4ed8' : '#fff',
          stroke: '#1d4ed8', 'stroke-width': '2'
        )
      end
    end
  end

  def series_to_plot
    @series_to_plot ||= @series
      .drop_while(&:zero?)
      .reverse
      .drop_while(&:zero?)
      .reverse
  end

  def leading_zeros_count
    @leading_zeros_count ||= @series.take_while(&:zero?).size
  end

  def plot_values
    @daily_mode ? @series : series_to_plot
  end

  def compute_points(width:, height:)
    values = plot_values
    return [] if values.empty?

    max = values.max
    min = @daily_mode ? [values.min, 0].min : values.min
    range = (max - min).nonzero? || max.nonzero? || 1.0
    step = values.size <= 1 ? 0 : width.to_f / (values.size - 1)

    pad_top    = height * 0.08
    pad_bottom = height * 0.08
    usable     = height - pad_top - pad_bottom

    values.each_with_index.map do |value, index|
      x = (index * step).round(2)
      normalized = (value - min) / range
      y = (height - pad_bottom - normalized * usable).round(2)
      [x, y]
    end
  end

  def line_path(pts)
    pts.each_with_index.map { |(x, y), idx| "#{idx.zero? ? 'M' : 'L'}#{x},#{y}" }.join(' ')
  end

  def area_path(pts, height)
    return '' if pts.empty?

    line = line_path(pts)
    last_x = pts.last.first
    "#{line} L#{last_x},#{height} L0,#{height} Z"
  end


  def label_text
    if @month
      month_name = I18n.t('date.month_names')[@month]
      I18n.t('hero_profit_card_component.label_month', month: month_name, year: @year)
    else
      I18n.t('hero_profit_card_component.label_year', year: @year)
    end
  end

  def subtitle_text
    return I18n.t('hero_profit_card_component.per_day_zero') if @days_count.to_i.zero?

    I18n.t('hero_profit_card_component.per_day', value: format_currency(@profit_per_day), count: @days_count)
  end

  def chart_labels
    return [] if @daily_mode

    MONTHS_PT[leading_zeros_count, series_to_plot.size] || []
  end
end

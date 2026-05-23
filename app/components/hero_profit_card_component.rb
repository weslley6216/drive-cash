class HeroProfitCardComponent < ApplicationComponent
  CHART_WIDTH  = 280
  CHART_HEIGHT = 80

  def initialize(profit:, change_percent:, profit_per_day:, days_count:, monthly_series:, year:, month: nil)
    @profit = profit
    @change_percent = change_percent
    @profit_per_day = profit_per_day
    @days_count = days_count
    @series = monthly_series
    @year = year
    @month = month
  end

  def view_template
    div(class: 'rounded-2xl bg-blue-50 border-2 border-blue-200 p-5 relative overflow-hidden animate-slide-up') do
      header_section
      subtitle_section
      chart_section
    end
  end

  private

  def header_section
    div(class: 'flex items-start justify-between mb-1') do
      div do
        p(class: 'text-xs font-medium text-blue-700 opacity-75') { label_text }
        p(class: 'text-3xl font-bold mt-1 tracking-tight text-blue-900') { format_currency(@profit) }
      end
      change_badge if @change_percent
    end
  end

  def subtitle_section
    p(class: 'text-sm text-blue-700/80 mt-1') { subtitle_text }
  end

  def chart_section
    return if chart_points.empty?

    div(class: 'mt-4') do
      svg(
        viewBox: "0 0 #{CHART_WIDTH} #{CHART_HEIGHT + 12}",
        class: 'w-full',
        style: "height: #{CHART_HEIGHT + 12}px",
        xmlns: 'http://www.w3.org/2000/svg'
      ) do |s|
        s.defs do
          s.linearGradient(id: 'profitFill', x1: '0', y1: '0', x2: '0', y2: '1') do
            s.stop(offset: '0%', 'stop-color': '#3b82f6', 'stop-opacity': '0.25')
            s.stop(offset: '100%', 'stop-color': '#3b82f6', 'stop-opacity': '0')
          end
        end

        s.path(d: area_path_definition, fill: 'url(#profitFill)')
        s.path(d: path_definition, fill: 'none', stroke: '#1d4ed8', 'stroke-width': '2.5', 'stroke-linecap': 'round', 'stroke-linejoin': 'round')

        chart_points.each_with_index do |(x, y), idx|
          last = idx == chart_points.size - 1
          s.circle(cx: x, cy: y, r: last ? 4 : 2.5, fill: last ? '#1d4ed8' : '#fff',
                   stroke: '#1d4ed8', 'stroke-width': '2')
        end
      end

      if chart_labels.any?
        div(class: 'flex justify-between text-[10px] text-blue-700 opacity-60 mt-1 px-1') do
          chart_labels.each { |label| span { label } }
        end
      end
    end
  end

  def change_badge
    positive = @change_percent.to_f >= 0
    color_classes = positive ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'
    text_key      = positive ? 'hero_profit_card_component.change_positive' : 'hero_profit_card_component.change_negative'

    span(class: class_names('text-xs font-semibold px-2 py-1 rounded-full', color_classes)) do
      I18n.t(text_key, value: @change_percent.to_s)
    end
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

  def chart_points
    @chart_points ||= compute_points
  end

  def compute_points
    return [] if @series.blank?

    full = @series.map(&:to_f)
    values = full.drop_while(&:zero?)
    values = values.reverse.drop_while(&:zero?).reverse
    return [] if values.empty? || values.all?(&:zero?)

    min = values.min
    max = values.max
    range = (max - min).nonzero? || 1.0
    step  = values.size == 1 ? 0 : CHART_WIDTH.to_f / (values.size - 1)

    values.each_with_index.map do |value, index|
      x = (index * step).round(2)
      y = (CHART_HEIGHT - ((value - min) / range * CHART_HEIGHT)).round(2)
      [x, y]
    end
  end

  def path_definition
    chart_points.each_with_index.map { |(x, y), idx| "#{idx.zero? ? 'M' : 'L'}#{x},#{y}" }.join(' ')
  end

  def area_path_definition
    return '' if chart_points.empty?

    line = chart_points.each_with_index.map { |(x, y), idx| "#{idx.zero? ? 'M' : 'L'}#{x},#{y}" }.join(' ')
    last_x = chart_points.last.first
    "#{line} L#{last_x},#{CHART_HEIGHT} L0,#{CHART_HEIGHT} Z"
  end

  def chart_labels
    @chart_labels ||= begin
      return [] if @series.blank?

      full = @series.map(&:to_f)
      leading_zeros  = full.take_while(&:zero?).size
      trailing_zeros = full.reverse.take_while(&:zero?).size
      months_pt = %w[Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez]
      months_pt[leading_zeros, full.size - leading_zeros - trailing_zeros] || []
    end
  end
end

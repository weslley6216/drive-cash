class HeroProfitCardComponent < ApplicationComponent
  CHART_WIDTH  = 280
  CHART_HEIGHT = 64

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
        p(class: 'text-xs font-medium text-blue-700 uppercase tracking-wider opacity-75') { label_text }
        p(class: 'text-3xl font-bold mt-1 tracking-tight text-blue-900') { format_currency(@profit) }
      end
      change_badge if @change_percent
    end
  end

  def subtitle_section
    p(class: 'text-sm text-blue-700 mt-2 opacity-80') { subtitle_text }
  end

  def chart_section
    return if chart_points.empty?

    div(class: 'mt-4') do
      svg(
        viewBox: "0 0 #{CHART_WIDTH} #{CHART_HEIGHT}",
        class: 'w-full h-16',
        xmlns: 'http://www.w3.org/2000/svg'
      ) do |s|
        s.path(d: path_definition, fill: 'none', stroke: '#1d4ed8', 'stroke-width': '2', 'stroke-linecap': 'round', 'stroke-linejoin': 'round')
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
    return [] if @series.blank? || @series.all? { |v| v.to_f.zero? }

    values = @series.map(&:to_f)
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
end

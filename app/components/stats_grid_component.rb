class StatsGridComponent < ApplicationComponent
  ICONS = {
    dollar_sign: PhlexIcons::Lucide::DollarSign,
    triangle_alert: PhlexIcons::Lucide::TriangleAlert,
    trending_up: PhlexIcons::Lucide::TrendingUp,
    calendar: PhlexIcons::Lucide::Calendar,
    package: PhlexIcons::Lucide::Package
  }.freeze

  TILES = [
    { key: :earnings, color: :green,  icon: :dollar_sign,    detail: :dashboard_earnings_detail_path },
    { key: :expenses, color: :red,    icon: :triangle_alert, detail: :dashboard_expenses_detail_path },
    { key: :days,     color: :yellow, icon: :calendar,       detail: nil },
    { key: :trips,    color: :purple, icon: :package,        detail: nil }
  ].freeze

  def initialize(totals:, month: nil, year: Date.current.year)
    @totals = totals
    @month = month
    @year = year
  end

  def view_template
    div(id: 'stats_grid', class: 'grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6') do
      TILES.each { |tile| render_card(tile) }
    end
  end

  private

  def annual_view? = @month.blank?

  def render_card(tile)
    config = {
      title: t("dashboard.index_view.stats.#{tile[:key]}.title"),
      value: send("#{tile[:key]}_value"),
      subtitle: send("#{tile[:key]}_subtitle"),
      color: tile[:color],
      icon: ICONS[tile[:icon]]
    }
    config[:href] = send(tile[:detail], year: @year, month: @month) if tile[:detail]

    render StatCardComponent.new(**config)
  end

  def earnings_value = format_currency(@totals[:earnings])
  def expenses_value = format_currency(@totals[:expenses])
  def days_value = @totals[:days].to_s
  def trips_value = @totals[:trips].to_s

  def earnings_subtitle
    key = annual_view? ? 'subtitle_annual' : 'subtitle_monthly'
    value = annual_view? ? @totals[:earnings_avg_month] : @totals[:earnings_avg_day]
    t("dashboard.index_view.stats.earnings.#{key}", value: format_currency(value))
  end

  def expenses_subtitle
    t('dashboard.index_view.stats.expenses.subtitle', percent: format_percentage(@totals[:expenses_percent]))
  end

  def days_subtitle
    if annual_view?
      formatted_avg = number_with_precision(@totals[:days_avg_month], precision: 0)
      t('dashboard.index_view.stats.days.subtitle_annual', value: formatted_avg)
    else
      t('dashboard.index_view.stats.days.subtitle_monthly', value: @totals[:days_avg_week])
    end
  end

  def trips_subtitle
    if annual_view?
      t('dashboard.index_view.stats.trips.subtitle_annual', value: @totals[:trips_avg_month])
    else
      t('dashboard.index_view.stats.trips.subtitle_monthly', value: @totals[:trips_avg_day])
    end
  end
end

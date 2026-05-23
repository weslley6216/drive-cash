class StatsGridComponent < ApplicationComponent
  ICONS = {
    dollar_sign: PhlexIcons::Lucide::DollarSign,
    triangle_alert: PhlexIcons::Lucide::TriangleAlert,
    trending_up: PhlexIcons::Lucide::TrendingUp,
    calendar: PhlexIcons::Lucide::Calendar,
    package: PhlexIcons::Lucide::Package
  }.freeze

  def initialize(totals:, month: nil, year: Date.current.year)
    @totals = totals
    @month = month
    @year = year
  end

  def view_template
    div(id: 'stats_grid', class: 'grid grid-cols-2 gap-3 mb-6') do
      earnings_card
      expenses_card
      trips_card
      days_card
    end
  end

  private

  def annual_view? = @month.blank?

  def earnings_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.earnings.title'),
      value: format_currency(@totals[:earnings]),
      subtitle: earnings_subtitle,
      color: :green,
      icon: ICONS[:dollar_sign],
      href: dashboard_earnings_detail_path(year: @year, month: @month)
    )
  end

  def expenses_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.expenses.title'),
      value: format_currency(@totals[:expenses]),
      subtitle: expenses_subtitle,
      color: :red,
      icon: ICONS[:triangle_alert],
      href: dashboard_expenses_detail_path(year: @year, month: @month)
    )
  end

  def days_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.days.title'),
      value: @totals[:days].to_s,
      subtitle: days_subtitle,
      color: :yellow,
      icon: ICONS[:calendar]
    )
  end

  def trips_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.trips.title'),
      value: @totals[:trips].to_s,
      subtitle: trips_subtitle,
      color: :purple,
      icon: ICONS[:package]
    )
  end

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

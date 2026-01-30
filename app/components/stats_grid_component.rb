class StatsGridComponent < ApplicationComponent
  Icons = {
    dollar_sign: PhlexIcons::Lucide::DollarSign,
    triangle_alert: PhlexIcons::Lucide::TriangleAlert,
    trending_up: PhlexIcons::Lucide::TrendingUp,
    calendar: PhlexIcons::Lucide::Calendar
  }.freeze

  def initialize(totals:, month: nil, year: Date.current.year)
    @totals = totals
    @month = month
    @year = year
  end

  def view_template
    div(id: 'stats_grid', class: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8') do
      earnings_card
      expenses_card
      profit_card
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
      icon: Icons[:dollar_sign],
      href: dashboard_earnings_detail_path(year: @year, month: @month)
    )
  end

  def expenses_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.expenses.title'),
      value: format_currency(@totals[:expenses]),
      subtitle: expenses_subtitle,
      color: :red,
      icon: Icons[:triangle_alert],
      href: dashboard_expenses_detail_path(year: @year, month: @month)
    )
  end

  def profit_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.profit.title'),
      value: format_currency(@totals[:profit]),
      subtitle: profit_subtitle,
      color: :blue,
      icon: Icons[:trending_up]
    )
  end

  def days_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.days.title'),
      value: @totals[:days].to_s,
      subtitle: days_subtitle,
      color: :yellow,
      icon: Icons[:calendar]
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

  def profit_subtitle
    t('dashboard.index_view.stats.profit.subtitle', value: format_currency(@totals[:profit_per_day]))
  end

  def days_subtitle
    if annual_view?
      formatted_avg = number_with_precision(@totals[:days_avg_month], precision: 0)
      t('dashboard.index_view.stats.days.subtitle_annual', value: formatted_avg)
    else
      t('dashboard.index_view.stats.days.subtitle_monthly', value: @totals[:days_avg_week])
    end
  end
end

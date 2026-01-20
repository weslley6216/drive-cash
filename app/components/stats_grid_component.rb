class StatsGridComponent < ApplicationComponent
  def initialize(totals:)
    @totals = totals
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

  def earnings_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.earnings.title'),
      value: format_currency(@totals[:earnings]),
      subtitle: t('dashboard.index_view.stats.earnings.subtitle', value: format_currency(@totals[:earnings_avg_month])),
      color: :green, icon: :dollar_sign
    )
  end

  def expenses_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.expenses.title'),
      value: format_currency(@totals[:expenses]),
      subtitle: t('dashboard.index_view.stats.expenses.subtitle', percent: format_percentage(@totals[:expenses_percent])),
      color: :red, icon: :alert_triangle
    )
  end

  def profit_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.profit.title'),
      value: format_currency(@totals[:profit]),
      subtitle: t('dashboard.index_view.stats.profit.subtitle', value: format_currency(@totals[:profit_per_day])),
      color: :blue, icon: :trending_up
    )
  end

  def days_card
    render StatCardComponent.new(
      title: t('dashboard.index_view.stats.days.title'),
      value: @totals[:days].to_s,
      subtitle: t('dashboard.index_view.stats.days.subtitle', value: format_decimal(@totals[:days_avg_month])),
      color: :yellow, icon: :calendar
    )
  end
end

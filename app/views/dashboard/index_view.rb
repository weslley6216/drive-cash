# frozen_string_literal: true

module Dashboard
  class IndexView < ApplicationComponent
    def initialize(totals:, filters: {})
      @totals = totals
      @filters = filters
    end

    def view_template
      render LayoutComponent.new(title: t('.title')) do
        header
        stats_grid
      end
    end

    private

    def header
      div(class: 'mb-8') do
        h1(class: 'text-4xl font-bold text-slate-800 mb-2') { t('.title') }
        p(class: 'text-slate-600') { t('.subtitle') }
      end
    end

    def stats_grid
      div(class: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8') do
        earnings_card
        expenses_card
        profit_card
        days_card
      end
    end

    def earnings_card
      render StatCardComponent.new(
        title: t('.stats.earnings.title'),
        value: format_currency(@totals[:earnings]),
        subtitle: t('.stats.earnings.subtitle', value: format_currency(@totals[:earnings_avg_month])),
        color: :green,
        icon: :dollar_sign
      )
    end

    def expenses_card
      render StatCardComponent.new(
        title: t('.stats.expenses.title'),
        value: format_currency(@totals[:expenses]),
        subtitle: t('.stats.expenses.subtitle', percent: format_percentage(@totals[:expenses_percent])),
        color: :red,
        icon: :alert_triangle
      )
    end

    def profit_card
      render StatCardComponent.new(
        title: t('.stats.profit.title'),
        value: format_currency(@totals[:profit]),
        subtitle: t('.stats.profit.subtitle', value: format_currency(@totals[:profit_per_day])),
        color: :blue,
        icon: :trending_up
      )
    end

    def days_card
      render StatCardComponent.new(
        title: t('.stats.days.title'),
        value: @totals[:days].to_s,
        subtitle: t('.stats.days.subtitle', value: format_decimal(@totals[:days_avg_month])),
        color: :yellow,
        icon: :calendar
      )
    end
  end
end

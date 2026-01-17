# frozen_string_literal: true

module Dashboard
  class IndexView < ApplicationComponent
    def initialize(totals:)
      @totals = totals
    end

    def view_template
      render LayoutComponent.new(title: 'Dashboard Shopee') do
        header
        stats_grid
      end
    end

    private

    def header
      div(class: 'mb-8') do
        h1(class: 'text-4xl font-bold text-slate-800 mb-2') { 'Dashboard Shopee' }
        p(class: 'text-slate-600') { 'Acompanhamento completo de entregas e finanças' }
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
        title: 'Total de Ganhos',
        value: format_currency(@totals[:earnings]),
        subtitle: "Média: #{format_currency(@totals[:earnings_avg_month])}/mês",
        color: :green,
        icon: :dollar_sign
      )
    end

    def expenses_card
      render StatCardComponent.new(
        title: 'Total de Gastos',
        value: format_currency(@totals[:expenses]),
        subtitle: "#{format_percentage(@totals[:expenses_percent])}% dos ganhos",
        color: :red,
        icon: :alert_triangle
      )
    end

    def profit_card
      render StatCardComponent.new(
        title: 'Lucro Líquido',
        value: format_currency(@totals[:profit]),
        subtitle: "#{format_currency(@totals[:profit_per_day])}/dia trabalhado",
        color: :blue,
        icon: :trending_up
      )
    end

    def days_card
      render StatCardComponent.new(
        title: 'Dias Trabalhados',
        value: @totals[:days].to_s,
        subtitle: "#{format_decimal(@totals[:days_avg_month])} dias/mês em média",
        color: :yellow,
        icon: :calendar
      )
    end
  end
end

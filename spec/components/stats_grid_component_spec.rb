# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatsGridComponent, type: :component do
  let(:totals) do
    {
      earnings: 1000.0,
      expenses: 300.0,
      profit: 700.0,
      days: 20,
      earnings_avg_month: 500.0,
      expenses_percent: 30.0,
      profit_per_day: 35.0,
      days_avg_month: 10.0
    }
  end

  describe '#view_template' do
    it 'renders all stat cards' do
      component = StatsGridComponent.new(totals: totals)
      html = view_context.render(component)

      expect(html).to include('R$')
      expect(html).to include('1.000,00')
      expect(html).to include('700,00')
      expect(html).to include('20')
    end

    it 'renders grid container with correct ID' do
      component = StatsGridComponent.new(totals: totals)
      html = view_context.render(component)

      expect(html).to include('id="stats_grid"')
    end

    it 'renders earnings card with green color' do
      component = StatsGridComponent.new(totals: totals)
      html = view_context.render(component)

      expect(html).to include('bg-green-50')
    end

    it 'renders expenses card with red color' do
      component = StatsGridComponent.new(totals: totals)
      html = view_context.render(component)

      expect(html).to include('bg-red-50')
    end

    it 'renders profit card with blue color' do
      component = StatsGridComponent.new(totals: totals)
      html = view_context.render(component)

      expect(html).to include('bg-blue-50')
    end

    it 'renders days card with yellow color' do
      component = StatsGridComponent.new(totals: totals)
      html = view_context.render(component)

      expect(html).to include('bg-yellow-50')
    end

    it 'renders all stat card titles' do
      component = StatsGridComponent.new(totals: totals)
      html = view_context.render(component)

      expect(html).to include(I18n.t('dashboard.index_view.stats.earnings.title'))
      expect(html).to include(I18n.t('dashboard.index_view.stats.expenses.title'))
      expect(html).to include(I18n.t('dashboard.index_view.stats.profit.title'))
      expect(html).to include(I18n.t('dashboard.index_view.stats.days.title'))
    end

    it 'handles zero values correctly' do
      zero_totals = {
        earnings: 0.0,
        expenses: 0.0,
        profit: 0.0,
        days: 0,
        earnings_avg_month: 0.0,
        expenses_percent: 0.0,
        profit_per_day: 0.0,
        days_avg_month: 0
      }

      component = StatsGridComponent.new(totals: zero_totals)
      html = view_context.render(component)

      expect(html.squish).to include('R$ 0,00')
    end
  end
end

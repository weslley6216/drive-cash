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
      days_avg_month: 10.0,
      earnings_avg_day: 50.0,
      days_avg_week: 0 # Default para evitar nils
    }
  end

  describe '#view_template' do
    it 'renders all stat cards' do
      component = StatsGridComponent.new(totals: totals, month: nil)
      html = view_context.render(component)

      expect(html).to include('R$')
      expect(html).to include('1.000,00')
      expect(html).to include('700,00')
      expect(html).to include('20')
    end

    it 'renders grid container with correct ID' do
      component = StatsGridComponent.new(totals: totals, month: nil)
      html = view_context.render(component)

      expect(html).to include('id="stats_grid"')
    end

    context 'when in annual view (month: nil)' do
      let(:component) { StatsGridComponent.new(totals: totals, month: nil) }
      let(:html) { view_context.render(component).squish }

      it 'renders monthly average for earnings' do
        expect(html).to include(
          I18n.t('dashboard.index_view.stats.earnings.subtitle_annual', value: 'R$ 500,00')
        )
      end

      it 'renders average days per month as integer' do
        expect(html).to include(
          I18n.t('dashboard.index_view.stats.days.subtitle_annual', value: '10')
        )
      end
    end

    context 'when in monthly view (jan 2025)' do
      # Mockamos o resultado que viria do Service.
      # Se trabalhou 10 dias em Jan/25 (4.4 semanas), a média é ~2.
      let(:totals_monthly) { totals.merge(days: 10, days_avg_week: 2) }
      let(:component) { StatsGridComponent.new(totals: totals_monthly, month: 1, year: 2025) }
      let(:html) { view_context.render(component).squish }

      it 'renders daily average for earnings' do
        expect(html).to include(
          I18n.t('dashboard.index_view.stats.earnings.subtitle_monthly', value: 'R$ 50,00')
        )
      end

      it 'renders weekly frequency for days as integer' do
        expect(html).to include(
          I18n.t('dashboard.index_view.stats.days.subtitle_monthly', value: '2')
        )
      end
    end
  end
end

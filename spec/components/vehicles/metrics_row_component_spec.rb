require 'rails_helper'

RSpec.describe Vehicles::MetricsRowComponent, type: :component do
  let(:metrics) do
    { cost_per_km: 0.27, revenue_per_km: 0.61, profit_per_km: 0.34, km_per_liter: 11.2 }
  end

  describe 'mobile variant' do
    it 'renders 3 metrics (cost, revenue, consumption)' do
      html = view_context.render(described_class.new(metrics: metrics))

      expect(html).to include(I18n.t('vehicle.metrics.cost_per_km'))
      expect(html).to include(I18n.t('vehicle.metrics.revenue_per_km'))
      expect(html).to include(I18n.t('vehicle.metrics.km_per_liter'))
    end

    it 'renders consumption value with km/L suffix' do
      html = view_context.render(described_class.new(metrics: metrics))

      expect(html).to include('11,2')
      expect(html).to include('km/L')
    end

    it 'shows empty value when km_per_liter is nil' do
      html = view_context.render(described_class.new(metrics: metrics.merge(km_per_liter: nil)))

      expect(html).to include(I18n.t('vehicle.metrics.empty_value'))
    end
  end

  describe 'desktop variant' do
    it 'renders 4 metrics (cost, revenue, profit, consumption)' do
      html = view_context.render(described_class.new(metrics: metrics, variant: :desktop))

      expect(html).to include(I18n.t('vehicle.metrics.cost_per_km'))
      expect(html).to include(I18n.t('vehicle.metrics.revenue_per_km'))
      expect(html).to include(I18n.t('vehicle.metrics.profit_per_km'))
      expect(html).to include(I18n.t('vehicle.metrics.km_per_liter'))
    end

    it 'uses red tone for cost, emerald for revenue, blue for profit' do
      html = view_context.render(described_class.new(metrics: metrics, variant: :desktop))

      expect(html).to include('bg-red-50')
      expect(html).to include('bg-emerald-50')
      expect(html).to include('bg-blue-50')
    end
  end
end

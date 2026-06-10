require 'rails_helper'

RSpec.describe Vehicles::OdometerHeroComponent, type: :component do
  describe '#view_template' do
    it 'renders odometer formatted in pt-BR' do
      html = view_context.render(described_class.new(current_km: 48_230, km_this_month: 1840))

      expect(html).to include('48.230')
      expect(html).to include('km')
    end

    it 'renders delta of the month with + prefix' do
      html = view_context.render(described_class.new(current_km: 48_230, km_this_month: 1840))

      expect(html).to include('1.840')
      expect(html).to include(I18n.t('vehicle.odometer.delta_this_month', value: '1.840'))
    end

    it 'renders update button' do
      html = view_context.render(described_class.new(current_km: 0, km_this_month: 0))

      expect(html).to include(I18n.t('vehicle.odometer.update'))
    end

    it 'uses dark gradient classes' do
      html = view_context.render(described_class.new(current_km: 0, km_this_month: 0))

      expect(html).to include('from-slate-800')
      expect(html).to include('to-slate-900')
    end

    it 'renders desktop size when variant is :desktop' do
      html = view_context.render(described_class.new(current_km: 10, km_this_month: 0, variant: :desktop))

      expect(html).to include('lg:text-5xl')
    end
  end
end

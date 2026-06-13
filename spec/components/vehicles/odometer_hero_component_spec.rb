require 'rails_helper'

RSpec.describe Vehicles::OdometerHeroComponent, type: :component do
  describe '#view_template' do
    it 'renders odometer formatted in pt-BR with unit' do
      html = view_context.render(described_class.new(current_km: 160_928, km_this_month: 1180, updated_days_ago: 3))

      expect(html).to include('160.928')
      expect(html).to include(I18n.t('vehicle.odometer.unit'))
    end

    it 'renders the month delta with + prefix' do
      html = view_context.render(described_class.new(current_km: 160_928, km_this_month: 1180, updated_days_ago: 3))

      expect(html).to include(I18n.t('vehicle.odometer.delta_month', value: '1.180'))
    end

    it 'shows a fresh pill without amber ring when updated recently' do
      html = view_context.render(described_class.new(current_km: 10, km_this_month: 0, updated_days_ago: 3))

      expect(html).to include(I18n.t('vehicle.odometer.fresh', count: 3))
      expect(html).not_to include('ring-amber-400/60')
    end

    it 'shows a pulsing stale nudge with amber ring beyond seven days' do
      html = view_context.render(described_class.new(current_km: 10, km_this_month: 0, updated_days_ago: 10))

      expect(html).to include(I18n.t('vehicle.odometer.stale', count: 10))
      expect(html).to include('animate-ping')
      expect(html).to include('ring-amber-400/60')
    end

    it 'treats a never-updated odometer as stale' do
      html = view_context.render(described_class.new(current_km: 10, km_this_month: 0, updated_days_ago: nil))

      expect(html).to include(I18n.t('vehicle.odometer.stale_unknown'))
      expect(html).to include('ring-amber-400/60')
    end

    it 'renders the camera update button on mobile' do
      html = view_context.render(described_class.new(current_km: 10, km_this_month: 0, updated_days_ago: 3))

      expect(html).to include(I18n.t('vehicle.odometer.update'))
    end

    it 'renders desktop sizing without the inline button' do
      html = view_context.render(described_class.new(current_km: 10, km_this_month: 0, updated_days_ago: 3, variant: :desktop))

      expect(html).to include('lg:text-5xl')
      expect(html).not_to include(I18n.t('vehicle.odometer.update'))
    end
  end
end

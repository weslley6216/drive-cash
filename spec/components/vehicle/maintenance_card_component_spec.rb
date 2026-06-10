require 'rails_helper'

RSpec.describe Vehicle::MaintenanceCardComponent, type: :component do
  let(:vehicle) { create(:vehicle, odometer_km: 48_000) }
  let(:maintenance) { create(:maintenance, vehicle: vehicle, name: 'Troca de óleo', category: 'oil_change') }

  describe '#view_template' do
    it 'renders maintenance name' do
      html = view_context.render(described_class.new(
        maintenance: maintenance, km_until: 770, days_until: 18, urgent: false, progress_pct: 75
      ))

      expect(html).to include('Troca de óleo')
    end

    it 'renders km and days remaining' do
      html = view_context.render(described_class.new(
        maintenance: maintenance, km_until: 770, days_until: 18, urgent: false, progress_pct: 75
      ))

      expect(html).to include(I18n.t('vehicle.maintenances.km_remaining', value: 770))
      expect(html).to include(I18n.t('vehicle.maintenances.days_remaining', value: 18))
    end

    it 'renders urgent badge when urgent' do
      html = view_context.render(described_class.new(
        maintenance: maintenance, km_until: 570, days_until: 8, urgent: true, progress_pct: 90
      ))

      expect(html).to include(I18n.t('vehicle.maintenances.urgent'))
      expect(html).to include('bg-amber-100')
    end

    it 'does not render urgent badge when not urgent' do
      html = view_context.render(described_class.new(
        maintenance: maintenance, km_until: 1500, days_until: 30, urgent: false, progress_pct: 50
      ))

      expect(html).not_to include(I18n.t('vehicle.maintenances.urgent'))
    end

    it 'renders mark-done button when variant is :desktop' do
      html = view_context.render(described_class.new(
        maintenance: maintenance, km_until: 770, days_until: 18, urgent: false, progress_pct: 75, variant: :desktop
      ))

      expect(html).to include(I18n.t('vehicle.maintenances.mark_done'))
    end
  end
end

require 'rails_helper'

RSpec.describe Vehicles::MaintenanceRowComponent, type: :component do
  def row_for(vehicle:, **overrides)
    maintenance = build(:maintenance, vehicle: vehicle, **overrides)
    Vehicles::MaintenanceService::Row.new(
      maintenance: maintenance,
      progress: maintenance.progress,
      km_until: maintenance.km_until,
      target: maintenance.target,
      status_key: maintenance.status_key
    )
  end

  describe '#view_template' do
    it 'renders an on-track item with catalog label and remaining km' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      row = row_for(vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000)

      html = view_context.render(described_class.new(row: row))

      expect(html).to include(I18n.t('vehicle.maintenances.catalog.oil_change'))
      expect(html).to include(I18n.t('vehicle.maintenances.status.ok'))
      expect(html).to include('faltam')
    end

    it 'renders an overdue item with the overdue copy and red color' do
      vehicle = create(:vehicle, odometer_km: 165_000)
      row = row_for(vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000)

      html = view_context.render(described_class.new(row: row))

      expect(html).to include(I18n.t('vehicle.maintenances.status.overdue'))
      expect(html).to include('venceu há')
      expect(html).to include('#dc2626')
    end

    it 'renders the mark done action on desktop' do
      vehicle = create(:vehicle, odometer_km: 160_000)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_000, interval_km: 5_000)
      row = Vehicles::MaintenanceService::Row.new(
        maintenance: maintenance,
        progress: maintenance.progress,
        km_until: maintenance.km_until,
        target: maintenance.target,
        status_key: maintenance.status_key
      )

      html = view_context.render(described_class.new(row: row, variant: :desktop))

      expect(html).to include(I18n.t('vehicle.maintenances.mark_done'))
    end
  end
end

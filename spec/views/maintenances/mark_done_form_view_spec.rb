require 'rails_helper'

RSpec.describe Maintenances::MarkDoneFormView, type: :component do
  describe '#view_template' do
    it 'renders title and subtitle from the maintenance' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600, interval_km: 5_000)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance)

      html = view_context.render(described_class.new(request: request))

      expect(html).to include('Troca de óleo feita')
      expect(html).to include('155.600')
      expect(html).to include('5.000')
    end

    it 'prefills done_km with the odometer' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance)

      html = view_context.render(described_class.new(request: request))

      expect(html).to include('value="160928"')
    end

    it 'lists only existing companions with the first checked' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 150_800)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance)

      html = view_context.render(described_class.new(request: request))

      expect(html).to include(I18n.t('vehicle.maintenances.catalog.oil_filter'))
      expect(html).not_to include(I18n.t('vehicle.maintenances.catalog.air_filter'))
      expect(html).to match(/type="checkbox"[^>]*checked/)
    end

    it 'omits the companions block for items without companions' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'tire_rotation', last_done_km: 150_000)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance)

      html = view_context.render(described_class.new(request: request))

      expect(html).not_to include(I18n.t('maintenances.mark_done.labels.companions'))
    end

    it 'renders the server error inline' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance, done_km: 154_900, companion_ids: [])
      request.valid?

      html = view_context.render(described_class.new(request: request))

      expect(html).to include(I18n.t('maintenances.mark_done.errors.below_last', km: '155.600'))
    end

    it 'exposes km rules to the Stimulus controller' do
      vehicle = create(:vehicle, odometer_km: 160_928)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600)
      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance)

      html = view_context.render(described_class.new(request: request))

      expect(html).to include('data-mark-done-km-odometer-value="160928"')
      expect(html).to include('data-mark-done-km-max-value="162928"')
      expect(html).to include('data-mark-done-km-last-km-value="155600"')
    end
  end
end

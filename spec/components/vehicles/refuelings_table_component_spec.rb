require 'rails_helper'

RSpec.describe Vehicles::RefuelingsTableComponent, type: :component do
  let(:vehicle) { create(:vehicle) }
  let(:entries) do
    [
      { refueling: create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', date: Date.new(2026, 5, 20), liters: 32.5, total_amount: 180.50), computed_km_per_liter: 11.4 },
      { refueling: create(:refueling, vehicle: vehicle, vendor: 'Posto Geladão', date: Date.new(2026, 5, 14), liters: 28.0, total_amount: 154.00), computed_km_per_liter: 11.0 }
    ]
  end

  describe '#view_template' do
    it 'renders table headers' do
      html = view_context.render(described_class.new(entries: entries))

      expect(html).to include(I18n.t('vehicle.refuelings.table_headers.vendor'))
      expect(html).to include(I18n.t('vehicle.refuelings.table_headers.total'))
    end

    it 'renders one row per refueling' do
      html = view_context.render(described_class.new(entries: entries))

      expect(html).to include('Posto Orense')
      expect(html).to include('Posto Geladão')
    end

    it 'renders empty state when entries is empty' do
      html = view_context.render(described_class.new(entries: []))

      expect(html).to include(I18n.t('vehicle.refuelings.empty'))
    end
  end
end

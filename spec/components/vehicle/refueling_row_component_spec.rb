require 'rails_helper'

RSpec.describe Vehicle::RefuelingRowComponent, type: :component do
  let(:vehicle) { create(:vehicle) }
  let(:refueling) { create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', liters: 32.5, total_amount: 180.50, date: Date.new(2026, 5, 20)) }

  describe '#view_template' do
    it 'renders vendor and total' do
      html = view_context.render(described_class.new(refueling: refueling, computed_km_per_liter: 11.4))

      expect(html).to include('Posto Orense')
      expect(html).to include('R$ 180,50')
    end

    it 'renders km/L when available' do
      html = view_context.render(described_class.new(refueling: refueling, computed_km_per_liter: 11.4))

      expect(html).to include('11,4 km/L')
    end

    it 'omits km/L when nil' do
      html = view_context.render(described_class.new(refueling: refueling, computed_km_per_liter: nil))

      expect(html).not_to include('km/L')
    end

    it 'shows fuel icon container' do
      html = view_context.render(described_class.new(refueling: refueling, computed_km_per_liter: nil))

      expect(html).to include('bg-red-50')
      expect(html).to include('text-red-600')
    end
  end
end

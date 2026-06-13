require 'rails_helper'

RSpec.describe Vehicles::TankBalanceCardComponent, type: :component do
  let(:fill) { create(:refueling, date: Date.new(2026, 6, 7), vendor: 'Posto Orense', liters: 44.1, total_amount: 260, full_tank: true) }

  describe '#view_template' do
    it 'renders the ok state with blue bar and the last fill line' do
      html = view_context.render(described_class.new(balance: 125, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.ok'))
      expect(html).to include('bg-blue-500')
      expect(html).to include('Posto Orense')
      expect(html).to include('R$ 125,00')
    end

    it 'renders the low state with amber styling' do
      html = view_context.render(described_class.new(balance: 50, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.low'))
      expect(html).to include(I18n.t('vehicle.tank.note.low'))
      expect(html).to include('bg-amber-500')
    end

    it 'renders the empty state note' do
      html = view_context.render(described_class.new(balance: 0, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.empty'))
      expect(html).to include(I18n.t('vehicle.tank.note.empty'))
      expect(html).to include('border-red-200')
    end

    it 'falls back to the tank title when the ok state has no recorded fill' do
      html = view_context.render(described_class.new(balance: 125, full: 260, last_fill: nil))

      expect(html).to include(I18n.t('vehicle.tank.status.ok'))
      expect(html).to include(I18n.t('vehicle.tank.title'))
    end

    it 'renders the negative state with a minus sign' do
      html = view_context.render(described_class.new(balance: -40, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.negative'))
      expect(html).to include('−R$ 40,00')
      expect(html).to include(I18n.t('vehicle.tank.note.negative'))
    end
  end
end

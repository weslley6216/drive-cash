require 'rails_helper'

RSpec.describe Vehicles::TankBalanceCardComponent, type: :component do
  let(:fill) { create(:refueling, date: Date.new(2026, 6, 7), vendor: 'Posto Orense', liters: 44.1, total_amount: 260, full_tank: true) }

  describe '#view_template' do
    it 'renders the ok state with blue bar and the last fill line' do
      html = view_context.render(described_class.new(balance: 220, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.ok'))
      expect(html).to include('bg-blue-500')
      expect(html).to include('Posto Orense')
      expect(html).to include('R$ 220,00')
    end

    it 'renders the mid state with amber styling between 50 and 75 percent' do
      html = view_context.render(described_class.new(balance: 150, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.mid'))
      expect(html).to include('bg-amber-500')
    end

    it 'renders the low state with orange styling between 25 and 50 percent' do
      html = view_context.render(described_class.new(balance: 80, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.low'))
      expect(html).to include('bg-orange-500')
    end

    it 'renders the critical state with red styling below 25 percent' do
      html = view_context.render(described_class.new(balance: 30, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.critical'))
      expect(html).to include('bg-red-500')
    end

    it 'renders the empty state note' do
      html = view_context.render(described_class.new(balance: 0, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.empty'))
      expect(html).to include(I18n.t('vehicle.tank.note.empty'))
    end

    it 'renders the negative state with a minus sign' do
      html = view_context.render(described_class.new(balance: -40, full: 260, last_fill: fill))

      expect(html).to include(I18n.t('vehicle.tank.status.negative'))
      expect(html).to include('−R$ 40,00')
    end

    it 'falls back to the tank title when the ok state has no recorded fill' do
      html = view_context.render(described_class.new(balance: 220, full: 260, last_fill: nil))

      expect(html).to include(I18n.t('vehicle.tank.title'))
    end

    it 'falls back to the tank title when the last fill has no liters' do
      fill_without_liters = create(:refueling, liters: nil, vendor: 'Posto Geladão')

      html = view_context.render(described_class.new(balance: 220, full: 260, last_fill: fill_without_liters))

      expect(html).to include(I18n.t('vehicle.tank.title'))
      expect(html).not_to include('L ·')
    end

    it 'renders the level label with percent and remaining-until-empty under the bar' do
      html = view_context.render(described_class.new(balance: 195, full: 260, last_fill: fill))

      expect(html).to include('75%')
      expect(html).to include('R$ 195,00')
    end

    it 'renders a fallback level label when full is nil' do
      html = view_context.render(described_class.new(balance: 0, full: nil, last_fill: nil))

      expect(html).to include(I18n.t('vehicle.tank.level_label_empty'))
    end
  end
end

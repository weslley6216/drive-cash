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

    it 'wraps the mobile card in the shared card style' do
      html = view_context.render(described_class.new(balance: 220, full: 260, last_fill: fill))

      expect(html).to include('rounded-xl shadow-sm border')
      expect(html).not_to include('rounded-2xl')
    end

    it 'renders the desktop subtitle and the fuller refuel CTA' do
      html = view_context.render(described_class.new(balance: 220, full: 260, last_fill: fill, variant: :desktop))

      expect(html).to include(I18n.t('vehicle.tank.subtitle'))
      expect(html).to include(I18n.t('vehicle.tank.refuel_desktop'))
      expect(html).to include(I18n.t('vehicle.tank.of_full_desktop', value: 'R$ 260,00'))
      expect(html).to include('rounded-2xl border-2')
    end

    context 'with the desktop variant' do
      it 'summarizes the last full tank and the routes consumed since it' do
        html = view_context.render(described_class.new(balance: 125, full: 260, last_fill: fill, consumed: { amount: 135, routes: 3 }, variant: :desktop))

        expect(html).to include('<p class="text-xs text-slate-500 leading-relaxed">Último cheio · 07 jun · Posto Orense<br>')
        expect(html).to include('<span class="text-slate-400">Consumido R$ 135,00 em 3 rotas</span>')
      end

      it 'keeps the summary instead of the level warning in a danger state' do
        html = view_context.render(described_class.new(balance: 30, full: 260, last_fill: fill, consumed: { amount: 230, routes: 5 }, variant: :desktop))

        expect(html).to include('Consumido R$ 230,00 em 5 rotas')
        expect(html).not_to include(I18n.t('vehicle.tank.note.critical'))
      end

      it 'counts a single route in the singular' do
        html = view_context.render(described_class.new(balance: 215, full: 260, last_fill: fill, consumed: { amount: 45, routes: 1 }, variant: :desktop))

        expect(html).to include('Consumido R$ 45,00 em 1 rota</span>')
      end

      it 'drops the consumption line when no route ran since the fill' do
        html = view_context.render(described_class.new(balance: 260, full: 260, last_fill: fill, consumed: { amount: 0, routes: 0 }, variant: :desktop))

        expect(html).to include('Último cheio · 07 jun · Posto Orense')
        expect(html).not_to include('Consumido')
      end

      it 'leaves the station out of the last full line when the fill has none' do
        fill_without_vendor = create(:refueling, date: Date.new(2026, 6, 7), vendor: nil, total_amount: 260, full_tank: true)

        html = view_context.render(described_class.new(balance: 260, full: 260, last_fill: fill_without_vendor, consumed: { amount: 0, routes: 0 }, variant: :desktop))

        expect(html).to include('Último cheio · 07 jun<br>')
      end

      it 'renders no desktop summary without a full tank' do
        html = view_context.render(described_class.new(balance: 50, full: nil, last_fill: nil, consumed: nil, variant: :desktop))

        expect(html).not_to include('Último cheio')
        expect(html).not_to include('Consumido')
      end
    end
  end
end

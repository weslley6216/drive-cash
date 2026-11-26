require 'rails_helper'

RSpec.describe Vehicles::TankMoveRowComponent, type: :component do
  describe '#view_template' do
    it 'renders a credit (refueling) in blue with a plus sign' do
      move = { kind: :credit, date: Date.new(2026, 6, 7), amount: 260, full_tank: true,
               vendor: 'Posto Orense', liters: 44.1, price_per_liter: 5.89 }

      html = view_context.render(described_class.new(move: move))

      expect(html).to include(I18n.t('vehicle.moves.full_tank'))
      expect(html).to include('Posto Orense')
      expect(html).to include('+R$ 260,00')
      expect(html).to include('text-blue-700')
    end

    it 'renders a debit (route consumption) in red with a minus sign' do
      move = { kind: :debit, date: Date.current, amount: -45, description: 'Rota Shopee' }

      html = view_context.render(described_class.new(move: move))

      expect(html).to include('Rota Shopee')
      expect(html).to include(I18n.t('vehicle.moves.fuel_expense'))
      expect(html).to include('−R$ 45,00')
      expect(html).to include('text-red-700')
    end

    it 'labels today and yesterday relatively' do
      move = { kind: :debit, date: Date.current, amount: -45, description: nil }

      html = view_context.render(described_class.new(move: move))

      expect(html).to include(I18n.t('vehicle.moves.today'))
      expect(html).to include(I18n.t('vehicle.moves.route'))
    end

    it 'titles a refueling that did not fill the tank as a plain refueling' do
      move = { kind: :credit, date: Date.new(2026, 6, 2), amount: 100, full_tank: false,
               vendor: 'Posto Orense', liters: 17, price_per_liter: 5.88 }

      html = view_context.render(described_class.new(move: move))

      expect(html).to include(I18n.t('vehicle.moves.partial_fill'))
      expect(html).not_to include(I18n.t('vehicle.moves.full_tank'))
    end

    it 'tags the row with its filter kind' do
      credit = view_context.render(described_class.new(move: { kind: :credit, date: Date.new(2026, 6, 2), amount: 100, full_tank: true }))
      debit = view_context.render(described_class.new(move: { kind: :debit, date: Date.new(2026, 6, 2), amount: -45 }))

      expect(credit).to include('data-tank-filter-target="row" data-tank-filter-kind="fill"')
      expect(debit).to include('data-tank-filter-target="row" data-tank-filter-kind="route"')
    end

    it 'keeps the mobile row at py-3 in slate-800 with its own bottom border' do
      move = { kind: :debit, date: Date.new(2026, 6, 9), amount: -45, description: 'Rota Shopee' }

      html = view_context.render(described_class.new(move: move))

      expect(html).to include('flex items-center gap-3 px-4 py-3 border-b border-slate-100')
      expect(html).to include('text-sm font-semibold text-slate-800 truncate')
    end

    context 'with the desktop variant' do
      it 'renders a debit as a taller borderless row titled in slate-900 with the fuel expense sub' do
        move = { kind: :debit, date: Date.new(2026, 6, 9), amount: -45, description: 'Rota Shopee' }

        html = view_context.render(described_class.new(move: move, variant: :desktop))

        expect(html).to include('flex items-center gap-3 px-4 py-3.5"')
        expect(html).to include('text-sm font-semibold text-slate-900 truncate')
        expect(html).to include("09 jun · #{I18n.t('vehicle.moves.fuel_expense_desktop')}")
      end

      it 'keeps the station detail under a desktop refueling' do
        move = { kind: :credit, date: Date.new(2026, 6, 7), amount: 260, full_tank: true,
                 vendor: 'Posto Orense', liters: 44.1, price_per_liter: 5.89 }

        html = view_context.render(described_class.new(move: move, variant: :desktop))

        expect(html).to include('07 jun · Posto Orense · 44,1 L · R$ 5,89/L')
        expect(html).not_to include(I18n.t('vehicle.moves.fuel_expense_desktop'))
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Vehicles::TankMoveRowComponent, type: :component do
  describe '#view_template' do
    it 'renders a credit (refueling) in blue with a plus sign' do
      move = { kind: :credit, date: Date.new(2026, 6, 7), amount: 260,
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
  end
end

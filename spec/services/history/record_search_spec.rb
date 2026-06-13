require 'rails_helper'

RSpec.describe History::RecordSearch do
  let(:user) { create(:user) }

  describe '#earnings' do
    it 'returns the scope untouched when the term is blank' do
      scope = user.earnings.all

      expect(described_class.new('').earnings(scope)).to eq(scope)
    end

    it 'matches notes case-insensitive' do
      match = create(:earning, user: user, platform: 'uber', notes: 'Madrugada produtiva')
      create(:earning, user: user, platform: 'ifood', notes: 'Tarde calma')

      result = described_class.new('madru').earnings(user.earnings)

      expect(result.map(&:id)).to eq([match.id])
    end

    it 'matches by platform label' do
      match = create(:earning, user: user, platform: 'uber', notes: nil)
      create(:earning, user: user, platform: 'ifood', notes: nil)

      result = described_class.new('uber').earnings(user.earnings)

      expect(result.map(&:id)).to eq([match.id])
    end
  end

  describe '#expenses' do
    it 'returns the scope untouched when the term is blank' do
      scope = user.expenses.all

      expect(described_class.new(nil).expenses(scope)).to eq(scope)
    end

    it 'matches vendor and description case-insensitive' do
      vendor_match = create(:expense, user: user, category: 'fuel', vendor: 'Posto Florense', description: nil)
      description_match = create(:expense, user: user, category: 'meals', vendor: nil, description: 'Lanche florido')
      create(:expense, user: user, category: 'meals', vendor: 'Lanchonete', description: 'Almoço')

      result = described_class.new('flor').expenses(user.expenses)

      expect(result.map(&:id)).to match_array([vendor_match.id, description_match.id])
    end

    it 'matches by category label' do
      match = create(:expense, user: user, category: 'fuel', vendor: 'Posto X')
      create(:expense, user: user, category: 'meals', vendor: 'Lanchonete')

      result = described_class.new('Combustível').expenses(user.expenses)

      expect(result.map(&:id)).to eq([match.id])
    end
  end
end

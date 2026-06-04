require 'rails_helper'

RSpec.describe Dashboard::AvailableYears do
  let(:user) { create(:user) }

  describe '.fetch' do
    it 'includes years that have earnings data' do
      create(:earning, user: user, date: '2023-06-01')

      result = described_class.fetch(user: user)

      expect(result).to include(2023)
    end

    it 'includes years that have expense data' do
      create(:expense, user: user, date: '2022-03-15', category: 'fuel')

      result = described_class.fetch(user: user)

      expect(result).to include(2022)
    end

    it 'always includes the current year' do
      result = described_class.fetch(user: user)

      expect(result).to include(Date.current.year)
    end

    it 'returns years in descending order' do
      create(:earning, user: user, date: '2022-01-01')
      create(:earning, user: user, date: '2024-01-01')

      result = described_class.fetch(user: user)

      expect(result).to eq(result.sort.reverse)
    end
  end
end

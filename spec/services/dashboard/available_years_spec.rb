require 'rails_helper'

RSpec.describe Dashboard::AvailableYears do
  describe '.fetch' do
    it 'includes years that have earnings data' do
      create(:earning, date: '2023-06-01')

      result = described_class.fetch

      expect(result).to include(2023)
    end

    it 'includes years that have expense data' do
      create(:expense, date: '2022-03-15', category: 'fuel')

      result = described_class.fetch

      expect(result).to include(2022)
    end

    it 'always includes the current year' do
      result = described_class.fetch

      expect(result).to include(Date.current.year)
    end

    it 'returns years in descending order' do
      create(:earning, date: '2022-01-01')
      create(:earning, date: '2024-01-01')

      result = described_class.fetch

      expect(result).to eq(result.sort.reverse)
    end
  end
end

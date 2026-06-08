require 'rails_helper'

RSpec.describe Dashboard::ScopeMonthCounter do
  describe '.count_for' do
    it 'returns 1 for an empty scope (clamp floor)' do
      result = described_class.count_for(Earning.none)

      expect(result).to eq(1)
    end

    it 'returns 1 when all records are in the same month' do
      create(:earning, date: Date.new(2025, 3, 1))
      create(:earning, date: Date.new(2025, 3, 15))

      result = described_class.count_for(Earning.all)

      expect(result).to eq(1)
    end

    it 'returns distinct month count when records span multiple months' do
      create(:earning, date: Date.new(2025, 1, 10))
      create(:earning, date: Date.new(2025, 3, 5))
      create(:earning, date: Date.new(2025, 3, 20))
      create(:earning, date: Date.new(2025, 7, 1))

      result = described_class.count_for(Earning.all)

      expect(result).to eq(3)
    end

    it 'returns an Integer (counted in database, not loaded into Ruby)' do
      create(:earning, date: Date.new(2025, 1, 10))
      create(:earning, date: Date.new(2025, 7, 1))

      result = described_class.count_for(Earning.all)

      expect(result).to be_an(Integer)
    end
  end
end

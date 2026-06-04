require 'rails_helper'

RSpec.describe Dashboard::ProfitSeriesService do
  let(:user) { create(:user) }

  describe '#monthly' do
    it 'returns a 12-month profit series for the year' do
      create(:earning, user: user, date: '2025-01-10', amount: 500.00)
      create(:expense, user: user, date: '2025-01-10', amount: 100.00, category: 'fuel', paid: true)
      create(:earning, user: user, date: '2025-02-01', amount: 1000.00)

      result = described_class.new(year: 2025, month: nil, user: user).monthly

      expect(result).to be_an(Array)
      expect(result.size).to eq(12)
      expect(result[0]).to eq(400.0)
      expect(result[1]).to eq(1000.0)
      expect(result[5]).to eq(0.0)
    end

    it 'ignores unpaid expenses' do
      create(:earning, user: user, date: '2025-01-10', amount: 500.00)
      create(:expense, user: user, date: '2025-01-12', amount: 999.00, category: 'maintenance', paid: false)

      result = described_class.new(year: 2025, month: nil, user: user).monthly

      expect(result[0]).to eq(500.0)
    end
  end

  describe '#daily' do
    it 'returns nil when no month is provided' do
      expect(described_class.new(year: 2025, month: nil, user: user).daily).to be_nil
    end

    it 'returns a daily profit series for each day of the month' do
      create(:earning, user: user, date: '2025-01-10', amount: 500.00)
      create(:expense, user: user, date: '2025-01-10', amount: 100.00, category: 'fuel', paid: true)

      result = described_class.new(year: 2025, month: 1, user: user).daily

      expect(result).to be_an(Array)
      expect(result.size).to eq(31)
      expect(result[9]).to eq(400.0)
      expect(result[0]).to eq(0.0)
    end
  end
end

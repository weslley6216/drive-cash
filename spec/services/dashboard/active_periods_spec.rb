require 'rails_helper'

RSpec.describe Dashboard::ActivePeriods do
  let(:user) { create(:user) }
  let(:today) { Date.new(2026, 5, 22) }

  describe '.fetch' do
    it 'maps each year with records to its months with records, in ascending order' do
      create(:earning, user: user, date: '2025-11-03')
      create(:expense, user: user, date: '2025-03-15', category: 'fuel')
      create(:earning, user: user, date: '2026-02-10')

      result = described_class.fetch(user: user, date: today)

      expect(result).to eq(2025 => [3, 11], 2026 => [2, 5])
      expect(result.keys).to eq([2025, 2026])
    end

    it 'always offers the current month of the current year, even without records' do
      result = described_class.fetch(user: user, date: today)

      expect(result).to eq(2026 => [5])
    end

    it 'leaves out the months after the current one' do
      create(:expense, user: user, date: '2026-07-10', category: 'insurance')
      create(:expense, user: user, date: '2027-01-10', category: 'insurance')

      result = described_class.fetch(user: user, date: today)

      expect(result).to eq(2026 => [5])
    end

    it 'lists a month with both kinds of record once, in a single query' do
      create(:earning, user: user, date: '2026-04-01')
      create(:expense, user: user, date: '2026-04-20', category: 'fuel')

      periods = nil
      queries = count_queries { periods = described_class.fetch(user: user, date: today) }

      expect(periods).to eq(2026 => [4, 5])
      expect(queries).to eq(1)
    end

    it 'ignores the records of other users' do
      create(:earning, user: create(:user), date: '2025-08-01')

      result = described_class.fetch(user: user, date: today)

      expect(result).to eq(2026 => [5])
    end
  end
end

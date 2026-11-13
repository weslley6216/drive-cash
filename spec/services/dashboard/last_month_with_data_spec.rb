require 'rails_helper'

RSpec.describe Dashboard::LastMonthWithData do
  let(:user) { create(:user) }

  describe '.fetch' do
    it 'returns the first day of the latest month with records before the given date' do
      create(:earning, user: user, date: Date.new(2026, 3, 10))
      create(:expense, user: user, date: Date.new(2026, 5, 20), category: 'fuel', paid: true)

      result = described_class.fetch(user: user, before: Date.new(2026, 7, 1))

      expect(result).to eq(Date.new(2026, 5, 1))
    end

    it 'finds a month of a previous year' do
      create(:earning, user: user, date: Date.new(2025, 12, 28))

      result = described_class.fetch(user: user, before: Date.new(2026, 7, 1))

      expect(result).to eq(Date.new(2025, 12, 1))
    end

    it 'ignores records on or after the given date' do
      create(:earning, user: user, date: Date.new(2026, 4, 10))
      create(:earning, user: user, date: Date.new(2026, 7, 1))
      create(:earning, user: user, date: Date.new(2026, 8, 5))

      result = described_class.fetch(user: user, before: Date.new(2026, 7, 1))

      expect(result).to eq(Date.new(2026, 4, 1))
    end

    it 'ignores unpaid expenses' do
      create(:expense, user: user, date: Date.new(2026, 5, 20), category: 'fuel', paid: false)

      result = described_class.fetch(user: user, before: Date.new(2026, 7, 1))

      expect(result).to be_nil
    end

    it 'returns nil when there are no records before the given date' do
      create(:earning, user: user, date: Date.new(2026, 9, 1))

      result = described_class.fetch(user: user, before: Date.new(2026, 7, 1))

      expect(result).to be_nil
    end

    it "ignores other users' records" do
      create(:earning, user: create(:user), date: Date.new(2026, 5, 20))

      result = described_class.fetch(user: user, before: Date.new(2026, 7, 1))

      expect(result).to be_nil
    end

    it 'answers in a single query' do
      create(:earning, user: user, date: Date.new(2026, 3, 10))
      create(:expense, user: user, date: Date.new(2026, 5, 20), category: 'fuel', paid: true)

      result = nil
      queries = count_queries { result = described_class.fetch(user: user, before: Date.new(2026, 7, 1)) }

      expect(result).to eq(Date.new(2026, 5, 1))
      expect(queries).to eq(1)
    end
  end
end

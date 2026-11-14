require 'rails_helper'

RSpec.describe Goals::RealisticTarget do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  def seed_closed_months(owner)
    create(:earning, user: owner, date: Date.new(2026, 8, 10), amount: 6500)
    create(:expense, user: owner, date: Date.new(2026, 8, 12), amount: 500, paid: true)
    create(:earning, user: owner, date: Date.new(2026, 9, 10), amount: 6300)
    create(:earning, user: owner, date: Date.new(2026, 10, 10), amount: 6441)
  end

  describe '.call' do
    it 'averages the profit of the three closed months and floors it to the hundred' do
      seed_closed_months(user)

      suggestion = described_class.call(user: user, date: Date.new(2026, 11, 14))

      expect(suggestion).to eq(6200)
    end

    it 'leaves the month being shown out of the average' do
      seed_closed_months(user)
      create(:earning, user: user, date: Date.new(2026, 11, 2), amount: 30_000)

      suggestion = described_class.call(user: user, date: Date.new(2026, 11, 14))

      expect(suggestion).to eq(6200)
    end

    it 'looks back across the turn of the year' do
      create(:earning, user: user, date: Date.new(2025, 11, 10), amount: 3000)
      create(:earning, user: user, date: Date.new(2025, 12, 10), amount: 3000)
      create(:earning, user: user, date: Date.new(2026, 1, 10), amount: 3000)

      suggestion = described_class.call(user: user, date: Date.new(2026, 2, 10))

      expect(suggestion).to eq(3000)
    end

    it 'returns nil when one of the three closed months has no activity' do
      create(:earning, user: user, date: Date.new(2026, 8, 10), amount: 6000)
      create(:earning, user: user, date: Date.new(2026, 10, 10), amount: 6000)

      suggestion = described_class.call(user: user, date: Date.new(2026, 11, 14))

      expect(suggestion).to be_nil
    end

    it 'returns nil when the average profit is not positive' do
      create(:expense, user: user, date: Date.new(2026, 8, 10), amount: 300, paid: true)
      create(:expense, user: user, date: Date.new(2026, 9, 10), amount: 300, paid: true)
      create(:earning, user: user, date: Date.new(2026, 10, 10), amount: 100)

      suggestion = described_class.call(user: user, date: Date.new(2026, 11, 14))

      expect(suggestion).to be_nil
    end

    it 'returns nil when the average rounds down to zero' do
      create(:earning, user: user, date: Date.new(2026, 8, 10), amount: 50)
      create(:earning, user: user, date: Date.new(2026, 9, 10), amount: 50)
      create(:earning, user: user, date: Date.new(2026, 10, 10), amount: 50)

      suggestion = described_class.call(user: user, date: Date.new(2026, 11, 14))

      expect(suggestion).to be_nil
    end

    it 'ignores activity from other users' do
      seed_closed_months(other_user)

      suggestion = described_class.call(user: user, date: Date.new(2026, 11, 14))

      expect(suggestion).to be_nil
    end

    it 'keeps the suggestion unaffected by other users activity' do
      seed_closed_months(user)
      create(:earning, user: other_user, date: Date.new(2026, 9, 10), amount: 90_000)

      suggestion = described_class.call(user: user, date: Date.new(2026, 11, 14))

      expect(suggestion).to eq(6200)
    end
  end
end

require 'rails_helper'

RSpec.describe Ai::Readers::Summary do
  describe '#call' do
    it 'returns profit/earnings/expenses for the given month' do
      user = create(:user)
      create(:earning, user: user, amount: 500, date: Date.new(2026, 6, 10))
      create(:expense, user: user, amount: 100, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:earnings]).to eq(500.0)
      expect(result[:expenses]).to eq(100.0)
      expect(result[:profit]).to eq(400.0)
    end

    it 'does not include records from other users' do
      user = create(:user)
      other = create(:user)
      create(:earning, user: other, amount: 9999, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:earnings]).to eq(0.0)
    end

    it 'defaults to current year when params are empty' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result).to have_key(:profit)
    end

    it 'compares the month profit with the previous month' do
      user = create(:user)
      create(:earning, user: user, amount: 600, date: Date.new(2026, 6, 10))
      create(:earning, user: user, amount: 400, date: Date.new(2026, 5, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:profit_change]).to eq(50.0)
    end

    it 'compares January with December of the previous year' do
      user = create(:user)
      create(:earning, user: user, amount: 300, date: Date.new(2026, 1, 10))
      create(:earning, user: user, amount: 200, date: Date.new(2025, 12, 10))

      result = described_class.new({ 'year' => 2026, 'month' => 1 }, user: user).call

      expect(result[:profit_change]).to eq(50.0)
    end

    it 'picks the best earning day of the month' do
      user = create(:user)
      create(:earning, user: user, amount: 200, date: Date.new(2026, 6, 10))
      create(:earning, user: user, amount: 300, date: Date.new(2026, 6, 12))
      create(:earning, user: user, amount: 50, date: Date.new(2026, 6, 12))

      result = described_class.new({ 'year' => 2026, 'month' => 6 }, user: user).call

      expect(result[:best_day]).to eq(date: Date.new(2026, 6, 12), amount: 350.0)
    end

    it 'echoes the period and leaves comparison and best day out of a yearly summary' do
      user = create(:user)
      create(:earning, user: user, amount: 500, date: Date.new(2026, 6, 10))

      result = described_class.new({ 'year' => 2026 }, user: user).call

      expect(result).to include(year: 2026, month: nil, profit_change: nil, best_day: nil)
    end
  end
end

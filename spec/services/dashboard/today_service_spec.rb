require 'rails_helper'

RSpec.describe Dashboard::TodayService do
  let(:user) { create(:user) }

  describe '#call' do
    it 'returns today totals when data exists' do
      create(:earning, user: user, date: Date.current, amount: 100, trips_count: 3)
      create(:earning, user: user, date: Date.current, amount: 50, trips_count: 2)
      create(:expense, user: user, date: Date.current, amount: 30, paid: true)

      result = described_class.new(user: user).call

      expect(result[:earnings]).to eq(150.0)
      expect(result[:expenses]).to eq(30.0)
      expect(result[:net]).to eq(120.0)
      expect(result[:trips_count]).to eq(5)
    end

    it 'only counts activity from today' do
      create(:earning, user: user, date: Date.current - 1, amount: 999)
      create(:earning, user: user, date: Date.current, amount: 100, trips_count: 1)

      result = described_class.new(user: user).call

      expect(result[:earnings]).to eq(100.0)
      expect(result[:net]).to eq(100.0)
    end

    it 'returns nil when no activity today' do
      result = described_class.new(user: user).call

      expect(result).to be_nil
    end
  end
end

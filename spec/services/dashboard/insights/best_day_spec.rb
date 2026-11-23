require 'rails_helper'

RSpec.describe Dashboard::Insights::BestDay do
  let(:user) { create(:user) }

  describe '#call' do
    it 'returns nil when month is nil' do
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          nil,
        previous_year:  2024,
        previous_month: nil,
        current_stats:  {},
        previous_stats: {},
        categories:     [],
        platforms:      []
      )

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when there are no earnings in the month' do
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          6,
        previous_year:  2024,
        previous_month: 6,
        current_stats:  {},
        previous_stats: {},
        categories:     [],
        platforms:      []
      )

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns the highest-grossing date and its amount as payload' do
      create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 500, trips_count: 1)
      create(:earning, user: user, date: Date.new(2025, 6, 15), amount: 200, trips_count: 1)
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          6,
        previous_year:  2024,
        previous_month: 6,
        current_stats:  {},
        previous_stats: {},
        categories:     [],
        platforms:      []
      )

      result = described_class.new(context).call

      expect(result[:type]).to eq('best_day')
      expect(result[:severity]).to eq('info')
      expect(result[:payload][:date]).to eq(Date.new(2025, 6, 10))
      expect(result[:payload][:amount]).to eq(500.0)
    end

    it 'sums multiple earnings on the same day before comparing' do
      create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 100, trips_count: 1)
      create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 250, trips_count: 1)
      create(:earning, user: user, date: Date.new(2025, 6, 15), amount: 300, trips_count: 1)
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          6,
        previous_year:  2024,
        previous_month: 6,
        current_stats:  {},
        previous_stats: {},
        categories:     [],
        platforms:      []
      )

      result = described_class.new(context).call

      expect(result[:payload][:date]).to eq(Date.new(2025, 6, 10))
      expect(result[:payload][:amount]).to eq(350.0)
    end
  end
end

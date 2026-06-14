require 'rails_helper'

RSpec.describe Dashboard::Insights::BestDay do
  let(:user) { create(:user) }

  def build_context(year:, month:)
    Dashboard::Insights::Context.new(
      user:           user,
      year:           year,
      month:          month,
      previous_year:  year - 1,
      previous_month: month,
      current_stats:  {},
      previous_stats: {},
      categories:     [],
      platforms:      []
    )
  end

  describe '#call' do
    it 'returns nil when month is nil' do
      context = build_context(year: 2025, month: nil)

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when there are no earnings in the month' do
      context = build_context(year: 2025, month: 6)

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns the highest-grossing date and its amount as payload' do
      create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 500, trips_count: 1)
      create(:earning, user: user, date: Date.new(2025, 6, 15), amount: 200, trips_count: 1)
      context = build_context(year: 2025, month: 6)

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
      context = build_context(year: 2025, month: 6)

      result = described_class.new(context).call

      expect(result[:payload][:date]).to eq(Date.new(2025, 6, 10))
      expect(result[:payload][:amount]).to eq(350.0)
    end
  end
end

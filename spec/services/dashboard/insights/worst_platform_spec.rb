require 'rails_helper'

RSpec.describe Dashboard::Insights::WorstPlatform do
  let(:user) { create(:user) }

  def build_context(platforms:)
    Dashboard::Insights::Context.new(
      user: user,
      year: 2025,
      month: 6,
      previous_year: 2024,
      previous_month: 6,
      current_stats: {},
      previous_stats: {},
      categories: [],
      platforms: platforms
    )
  end

  describe '#call' do
    it 'returns nil when fewer than two platforms have earnings' do
      context = build_context(platforms: [{ id: 'uber', label: 'Uber', amount: 500, trips_count: 5 }])

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when the last platform has zero trips' do
      context = build_context(platforms: [
        { id: 'uber',   label: 'Uber',   amount: 500, trips_count: 5 },
        { id: 'shopee', label: 'Shopee', amount:  50, trips_count: 0 }
      ])

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns a payload with platform label and per_trip computed from amount/trips' do
      context = build_context(platforms: [
        { id: 'uber',   label: 'Uber',   amount: 500, trips_count: 10 },
        { id: 'shopee', label: 'Shopee', amount: 100, trips_count: 4 }
      ])

      result = described_class.new(context).call

      expect(result[:type]).to eq('worst_platform')
      expect(result[:severity]).to eq('info')
      expect(result[:payload][:platform]).to eq('Shopee')
      expect(result[:payload][:per_trip]).to eq(25.0)
    end
  end
end

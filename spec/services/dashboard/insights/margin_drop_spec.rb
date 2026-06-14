require 'rails_helper'

RSpec.describe Dashboard::Insights::MarginDrop do
  let(:user) { create(:user) }

  def build_context(current_stats:, previous_stats:)
    Dashboard::Insights::Context.new(
      user:           user,
      year:           2025,
      month:          2,
      previous_year:  2024,
      previous_month: 2,
      current_stats:  current_stats,
      previous_stats: previous_stats,
      categories:     [],
      platforms:      []
    )
  end

  describe '#call' do
    it 'returns nil when previous margin is zero' do
      context = build_context(
        current_stats:  { profit: 100, earnings: 1000 },
        previous_stats: { profit: 0,   earnings: 0 }
      )

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when margin dropped by less than 5 percentage points' do
      context = build_context(
        current_stats:  { profit: 700, earnings: 1000 },
        previous_stats: { profit: 730, earnings: 1000 }
      )

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns a critical payload with raw pp difference and current margin' do
      context = build_context(
        current_stats:  { profit: 100, earnings: 1000 },
        previous_stats: { profit: 900, earnings: 1000 }
      )

      result = described_class.new(context).call

      expect(result[:type]).to eq('margin_drop')
      expect(result[:severity]).to eq('critical')
      expect(result[:payload][:pp]).to eq(80.0)
      expect(result[:payload][:current_margin]).to eq(10.0)
    end
  end
end

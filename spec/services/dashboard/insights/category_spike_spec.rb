require 'rails_helper'

RSpec.describe Dashboard::Insights::CategorySpike do
  let(:user) { create(:user) }

  describe '#call' do
    it 'returns nil when there are no categories' do
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          6,
        previous_year:  2025,
        previous_month: 5,
        current_stats:  {},
        previous_stats: {},
        categories:     [],
        platforms:      []
      )

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when previous period has no spending for the top category' do
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          6,
        previous_year:  2025,
        previous_month: 5,
        current_stats:  {},
        previous_stats: {},
        categories:     [{ id: 'fuel', label: 'Combustível', amount: 200 }],
        platforms:      []
      )

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when the increase is at or below the threshold' do
      create(:expense, user: user, date: Date.new(2025, 5, 1), amount: 200, category: 'fuel', paid: true)
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          6,
        previous_year:  2025,
        previous_month: 5,
        current_stats:  {},
        previous_stats: {},
        categories:     [{ id: 'fuel', label: 'Combustível', amount: 220 }],
        platforms:      []
      )

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns a payload with type, severity and raw values when above threshold (monthly)' do
      create(:expense, user: user, date: Date.new(2025, 5, 1), amount: 100, category: 'fuel', paid: true)
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          6,
        previous_year:  2025,
        previous_month: 5,
        current_stats:  {},
        previous_stats: {},
        categories:     [{ id: 'fuel', label: 'Combustível', amount: 220 }],
        platforms:      []
      )

      result = described_class.new(context).call

      expect(result[:type]).to eq('category_spike')
      expect(result[:severity]).to eq('warning')
      expect(result[:payload][:mode]).to eq(:monthly)
      expect(result[:payload][:category]).to eq('Combustível')
      expect(result[:payload][:pct]).to eq(120.0)
      expect(result[:payload][:amount]).to eq(220.0)
      expect(result[:payload][:previous_year]).to eq(2025)
      expect(result[:payload][:month]).to eq(6)
      expect(result[:payload][:previous_month]).to eq(5)
    end

    it 'sets mode :annual when month is nil and uses paid expenses across the year' do
      create(:expense, user: user, date: Date.new(2024, 3, 1), amount: 100, category: 'fuel', paid: true)
      context = Dashboard::Insights::Context.new(
        user:           user,
        year:           2025,
        month:          nil,
        previous_year:  2024,
        previous_month: nil,
        current_stats:  {},
        previous_stats: {},
        categories:     [{ id: 'fuel', label: 'Combustível', amount: 220 }],
        platforms:      []
      )

      result = described_class.new(context).call

      expect(result[:payload][:mode]).to eq(:annual)
      expect(result[:payload][:month]).to be_nil
    end
  end
end

require 'rails_helper'

RSpec.describe Dashboard::Insights::CategorySpike do
  let(:user) { create(:user) }

  def build_context(year:, month:, categories:)
    Dashboard::Insights::Context.new(
      user: user,
      year: year,
      month: month,
      previous_year: year - 1,
      previous_month: month,
      current_stats: {},
      previous_stats: {},
      categories: categories,
      platforms: []
    )
  end

  describe '#call' do
    it 'returns nil when there are no categories' do
      context = build_context(year: 2025, month: 6, categories: [])

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when previous period has no spending for the top category' do
      context = build_context(year: 2025, month: 6, categories: [{ id: 'fuel', label: 'Combustível', amount: 200 }])

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns nil when the increase is at or below the threshold' do
      create(:expense, user: user, date: Date.new(2024, 6, 1), amount: 200, category: 'fuel', paid: true)
      context = build_context(year: 2025, month: 6, categories: [{ id: 'fuel', label: 'Combustível', amount: 220 }])

      expect(described_class.new(context).call).to be_nil
    end

    it 'returns a payload with type, severity and raw values when above threshold (monthly)' do
      create(:expense, user: user, date: Date.new(2024, 6, 1), amount: 100, category: 'fuel', paid: true)
      context = build_context(year: 2025, month: 6, categories: [{ id: 'fuel', label: 'Combustível', amount: 220 }])

      result = described_class.new(context).call

      expect(result[:type]).to eq('category_spike')
      expect(result[:severity]).to eq('warning')
      expect(result[:payload][:mode]).to eq(:monthly)
      expect(result[:payload][:category]).to eq('Combustível')
      expect(result[:payload][:pct]).to eq(120.0)
      expect(result[:payload][:amount]).to eq(220.0)
      expect(result[:payload][:previous_year]).to eq(2024)
      expect(result[:payload][:month]).to eq(6)
    end

    it 'sets mode :annual when month is nil and uses paid expenses across the year' do
      create(:expense, user: user, date: Date.new(2024, 3, 1), amount: 100, category: 'fuel', paid: true)
      context = build_context(year: 2025, month: nil, categories: [{ id: 'fuel', label: 'Combustível', amount: 220 }])
      stub = Dashboard::Insights::Context.new(
        **context.to_h.merge(previous_month: nil)
      )

      result = described_class.new(stub).call

      expect(result[:payload][:mode]).to eq(:annual)
      expect(result[:payload][:month]).to be_nil
    end
  end
end

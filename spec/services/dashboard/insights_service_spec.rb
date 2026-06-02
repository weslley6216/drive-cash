require 'rails_helper'

RSpec.describe Dashboard::InsightsService do
  describe '#call' do
    context 'metrics' do
      it 'returns per_day, per_trip, per_hour, margin and change_pct hash' do
        create(:earning, date: Date.new(2025, 2, 1), amount: 800, trips_count: 10)
        create(:earning, date: Date.new(2025, 2, 5), amount: 200, trips_count: 10)
        create(:expense, date: Date.new(2025, 2, 1), amount: 200, category: 'fuel', paid: true)
        create(:earning, date: Date.new(2025, 1, 1), amount: 600, trips_count: 20)
        create(:expense, date: Date.new(2025, 1, 1), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 2).call

        expect(result[:metrics][:per_day]).to eq(400.0)
        expect(result[:metrics][:per_trip].to_f.round(2)).to eq(40.0)
        expect(result[:metrics][:per_hour].to_f.round(2)).to eq(50.0)
        expect(result[:metrics][:margin]).to eq(80.0)
        expect(result[:metrics][:change_pct]).to be_a(Hash)
        expect(result[:metrics][:change_pct].keys).to match_array(%i[per_day per_trip per_hour margin])
      end

      it 'returns zero for per_trip when there are no trips' do
        result = described_class.new(year: 2025, month: 2).call

        expect(result[:metrics][:per_trip]).to eq(0)
        expect(result[:metrics][:per_hour]).to eq(0)
        expect(result[:metrics][:margin]).to eq(0)
      end

      it 'returns nil for change_pct when previous period is empty' do
        create(:earning, date: Date.new(2025, 2, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2025, month: 2).call

        expect(result[:metrics][:change_pct][:per_day]).to be_nil
      end

      it 'compares to previous year when month is nil' do
        create(:earning, date: Date.new(2025, 6, 1), amount: 200, trips_count: 1)
        create(:earning, date: Date.new(2024, 6, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2025, month: nil).call

        expect(result[:metrics][:change_pct][:per_day]).to eq(100.0)
      end

      it 'wraps to december of previous year when month is january' do
        create(:earning, date: Date.new(2025, 1, 1),  amount: 200, trips_count: 1)
        create(:earning, date: Date.new(2024, 12, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2025, month: 1).call

        expect(result[:metrics][:change_pct][:per_day]).to eq(100.0)
      end
    end
  end
end

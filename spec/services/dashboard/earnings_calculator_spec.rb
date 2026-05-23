require 'rails_helper'

RSpec.describe Dashboard::EarningsCalculator do
  subject(:calculator) { described_class.new(Earning.all) }

  before do
    create(:earning, date: '2025-01-01', amount: 200, platform: 'shopee')
    create(:earning, date: '2025-01-01', amount: 300, platform: 'uber')
    create(:earning, date: '2025-02-01', amount: 500, platform: 'shopee')
  end

  describe '#call' do
    let(:result) { calculator.call }

    it 'calculates total earnings' do
      expect(result[:total]).to eq(1000.0)
    end

    it 'counts distinct working days' do
      expect(result[:days_count]).to eq(2)
    end

    it 'calculates average per day' do
      expect(result[:avg_per_day]).to eq(500.0)
    end

    it 'calculates average per month' do
      expect(result[:avg_per_month]).to eq(500.0)
    end


    it 'sums trips_count across all earnings' do
      expect(result[:trips_count]).to eq(3)
    end

    it 'groups earnings by platform' do
      expect(result[:by_platform]['shopee']).to eq(700.0)
      expect(result[:by_platform]['uber']).to eq(300.0)
    end
  end

  describe '#monthly_totals' do
    it 'returns a 12-month array of profit-eligible earnings sums' do
      create(:earning, date: Date.new(2026, 1, 10), amount: 100)
      create(:earning, date: Date.new(2026, 1, 20), amount: 50)
      create(:earning, date: Date.new(2026, 6, 5),  amount: 200)

      scope = Earning.for_year(2026)

      result = described_class.new(scope).monthly_totals

      expect(result.size).to eq(12)
      expect(result[0]).to eq(150.0)
      expect(result[5]).to eq(200.0)
      expect(result[11]).to eq(0.0)
    end
  end
end

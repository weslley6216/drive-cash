# spec/services/dashboard/earnings_calculator_spec.rb
require 'rails_helper'

RSpec.describe Dashboard::EarningsCalculator do
  let(:earning1) { create(:earning, date: '2025-01-01', amount: 200, platform: 'shopee') }
  let(:earning2) { create(:earning, date: '2025-01-01', amount: 300, platform: 'uber') } # Mesmo dia
  let(:earning3) { create(:earning, date: '2025-02-01', amount: 500, platform: 'shopee') } # Outro mês

  subject(:calculator) { described_class.new(Earning.all) }

  before { earning1; earning2; earning3 }

  describe '#call' do
    let(:result) { calculator.call }

    it 'calculates total earnings' do
      expect(result[:total]).to eq(1000.0)
    end

    it 'counts distinct working days' do
      expect(result[:days_count]).to eq(2) # 01/01 e 01/02
    end

    it 'calculates average per day' do
      expect(result[:avg_per_day]).to eq(500.0) # 1000 / 2 dias
    end

    it 'calculates average per month' do
      expect(result[:avg_per_month]).to eq(500.0) # 1000 / 2 meses
    end

    it 'groups by platform' do
      expect(result[:by_platform]['shopee']).to eq(700.0)
      expect(result[:by_platform]['uber']).to eq(300.0)
    end
  end
end

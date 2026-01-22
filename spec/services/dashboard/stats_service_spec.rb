require 'rails_helper'

RSpec.describe Dashboard::StatsService do
  subject(:service) { described_class.new(year: 2025, month: 1) }

  before do
    create(:earning, date: '2025-01-10', amount: 500.00)
    create(:expense, date: '2025-01-10', amount: 100.00, category: 'fuel')
    create(:earning, date: '2025-02-01', amount: 1000.00)
  end

  describe '#call' do
    let(:result) { service.call }

    it 'calculates total earnings for the period' do
      expect(result[:earnings]).to eq(500.00)
    end

    it 'calculates total expenses for the period' do
      expect(result[:expenses]).to eq(100.00)
    end

    it 'calculates profit' do
      expect(result[:profit]).to eq(400.00)
    end

    it 'calculates profit per day' do
      expect(result[:profit_per_day]).to eq(400.00)
    end

    it 'calculates expenses percentage' do
      expect(result[:expenses_percent]).to eq(20.0)
    end
  end
end

require 'rails_helper'

RSpec.describe Goals::MetricValue do
  describe '.of' do
    it 'subtracts spent from earned for a profit goal' do
      goal = build(:goal, metric: 'profit')

      result = described_class.of(goal, earned: 500, spent: 200)

      expect(result).to eq(300)
    end

    it 'ignores spent for an earnings goal' do
      goal = build(:goal, metric: 'earnings')

      result = described_class.of(goal, earned: 500, spent: 200)

      expect(result).to eq(500)
    end
  end
end

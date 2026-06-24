require 'rails_helper'

RSpec.describe Goals::Creator do
  describe '#call' do
    it 'creates a monthly goal with auto period' do
      user = create(:user)
      date = Date.new(2026, 6, 15)
      attrs = { 'kind' => 'monthly', 'target_amount' => 3000.0, 'metric' => 'profit' }

      result = described_class.new(attrs, user: user, date: date).call

      expect(result.success?).to be true
      expect(result.goal.period_start).to eq(Date.new(2026, 6, 1))
      expect(result.goal.period_end).to eq(Date.new(2026, 6, 30))
      expect(result.goal.target_amount).to eq(3000.0)
    end

    it 'creates an annual goal with auto period' do
      user = create(:user)
      date = Date.new(2026, 6, 15)
      attrs = { 'kind' => 'annual', 'target_amount' => 36000.0 }

      result = described_class.new(attrs, user: user, date: date).call

      expect(result.goal.period_start).to eq(Date.new(2026, 1, 1))
      expect(result.goal.period_end).to eq(Date.new(2026, 12, 31))
    end

    it 'creates a weekly goal with auto period' do
      user = create(:user)
      date = Date.new(2026, 6, 15)
      attrs = { 'kind' => 'weekly', 'target_amount' => 700.0 }

      result = described_class.new(attrs, user: user, date: date).call

      expect(result.success?).to be true
      expect(result.goal.period_start).to eq(date.beginning_of_week)
      expect(result.goal.period_end).to eq(date.end_of_week)
    end

    it 'defaults metric to profit when not provided' do
      user = create(:user)
      attrs = { 'kind' => 'monthly', 'target_amount' => 1000.0 }

      result = described_class.new(attrs, user: user, date: Date.new(2026, 6, 1)).call

      expect(result.goal.metric).to eq('profit')
    end

    it 'returns failure when kind is invalid' do
      user = create(:user)
      attrs = { 'kind' => 'invalid', 'target_amount' => 100.0 }

      result = described_class.new(attrs, user: user).call

      expect(result.success?).to be false
      expect(result.goal.errors).to be_present
    end
  end
end

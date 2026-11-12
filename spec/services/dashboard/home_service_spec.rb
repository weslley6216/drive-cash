require 'rails_helper'

RSpec.describe Dashboard::HomeService do
  let(:user) { create(:user) }

  describe '#call' do
    it 'shares one year ledger across stats, categories and the monthly goal' do
      allow(Dashboard::YearLedger).to receive(:new).and_call_original

      described_class.new(user: user, year: 2026, month: 3, reference_date: Date.new(2026, 3, 31)).call

      expect(Dashboard::YearLedger).to have_received(:new).once
    end

    it 'returns the monthly goal progress equal to the month profit' do
      create(:earning, user: user, date: Date.new(2026, 3, 5), amount: 500)
      create(:expense, user: user, date: Date.new(2026, 3, 6), amount: 120, category: 'fuel', paid: true)
      create(:goal, user: user, kind: 'monthly', metric: 'profit', target_amount: 1000,
             period_start: Date.new(2026, 3, 1), period_end: Date.new(2026, 3, 31))

      result = described_class.new(user: user, year: 2026, month: 3, reference_date: Date.new(2026, 3, 31)).call

      expect(result[:monthly_goal][:current]).to eq(result[:totals][:profit])
      expect(result[:monthly_goal][:current]).to eq(380)
    end

    it 'skips the monthly goal without a reference date' do
      result = described_class.new(user: user, year: 2026, month: 3, reference_date: nil).call

      expect(result[:monthly_goal]).to be_nil
    end

    it 'returns the payload keys the index view expects' do
      result = described_class.new(user: user, year: 2026, month: 3, reference_date: Date.new(2026, 3, 31)).call

      expect(result.keys).to eq(%i[totals recent_activity categories today monthly_goal])
    end
  end
end

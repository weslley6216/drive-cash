require 'rails_helper'

RSpec.describe Dashboard::EarningsDetailService do
  describe '#call' do
    context 'with month filter' do
      it 'returns earnings list and total' do
        earning1 = create(:earning, date: Date.new(2025, 1, 15), amount: 100)
        earning2 = create(:earning, date: Date.new(2025, 1, 20), amount: 250)

        result = described_class.new(year: 2025, month: 1).call

        expect(result[:annual]).to eq(false)
        expect(result[:earnings_by_month]).to be_nil
        expect(result[:earnings].to_a).to match_array([earning1, earning2])
        expect(result[:total]).to eq(350.0)
      end
    end

    context 'without month filter' do
      it 'returns earnings grouped by month and total' do
        create(:earning, date: Date.new(2025, 1, 10), amount: 100)
        create(:earning, date: Date.new(2025, 1, 20), amount: 50)
        create(:earning, date: Date.new(2025, 2, 15), amount: 200)

        result = described_class.new(year: 2025, month: nil).call

        expect(result[:annual]).to eq(true)
        expect(result[:earnings]).to eq(Earning.none)
        expect(result[:earnings_by_month].size).to eq(2)
        expect(result[:earnings_by_month].map { |r| r[:month_name] }).to include('janeiro', 'fevereiro')
        expect(result[:earnings_by_month].find { |r| r[:month_name] == 'janeiro' }[:total]).to eq(150.0)
        expect(result[:earnings_by_month].find { |r| r[:month_name] == 'fevereiro' }[:total]).to eq(200.0)
        expect(result[:total]).to eq(350.0)
      end
    end
  end
end

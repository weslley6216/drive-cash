require 'rails_helper'

RSpec.describe Dashboard::EarningsDetailService do
  describe '#call' do
    context 'with month filter (monthly detail)' do
      let(:trip) { create(:trip) }
      let!(:earning1) { create(:earning, trip: trip, date: Date.new(2025, 1, 15), amount: 100) }
      let!(:earning2) { create(:earning, trip: trip, date: Date.new(2025, 1, 20), amount: 250) }

      subject(:service) { described_class.new(year: 2025, month: 1) }

      it 'returns earnings list and total' do
        result = service.call

        expect(result[:annual]).to eq(false)
        expect(result[:earnings_by_month]).to be_nil
        expect(result[:earnings].to_a).to match_array([earning1, earning2])
        expect(result[:total]).to eq(350.0)
      end
    end

    context 'without month filter (annual detail)' do
      let(:trip) { create(:trip) }
      let!(:jan1) { create(:earning, trip: trip, date: Date.new(2025, 1, 10), amount: 100) }
      let!(:jan2) { create(:earning, trip: trip, date: Date.new(2025, 1, 20), amount: 50) }
      let!(:feb) { create(:earning, trip: trip, date: Date.new(2025, 2, 15), amount: 200) }

      subject(:service) { described_class.new(year: 2025, month: nil) }

      it 'returns earnings by month and total' do
        result = service.call

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

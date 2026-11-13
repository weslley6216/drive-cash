require 'rails_helper'

RSpec.describe Dashboard::InsightsService do
  let(:user) { create(:user) }

  describe '#call' do
    context 'metrics' do
      it 'returns per_day, per_trip, per_km and margin' do
        vehicle = create(:vehicle, user: user)
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 800, trips_count: 10)
        create(:earning, user: user, date: Date.new(2025, 2, 5), amount: 200, trips_count: 10)
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount: 200, category: 'fuel', paid: true)
        create(:refueling, vehicle: vehicle, date: Date.new(2025, 2, 1), odometer_km: 10_000)
        create(:refueling, vehicle: vehicle, date: Date.new(2025, 2, 5), odometer_km: 10_800)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:per_day]).to eq(400.0)
        expect(result[:metrics][:per_trip].to_f.round(2)).to eq(40.0)
        expect(result[:metrics][:per_km]).to eq(1.0)
        expect(result[:metrics][:margin]).to eq(80.0)
      end

      it 'exposes the monthly series of each metric' do
        create(:earning, user: user, date: Date.new(2025, 1, 1), amount: 200, trips_count: 2)
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 300, trips_count: 3)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:series].keys).to match_array(%i[per_day per_trip per_km margin])
        expect(result[:metrics][:series][:per_day][:points].map { |point| point[:month] }).to eq([1, 2])
      end

      it 'does not expose a comparison with another period' do
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 300, trips_count: 3)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics]).not_to have_key(:change_pct)
        expect(result).not_to have_key(:period_context)
      end

      it 'exposes the period earnings and expenses totals' do
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 800, trips_count: 10)
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount: 200, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:earnings]).to eq(800)
        expect(result[:metrics][:expenses]).to eq(200)
      end

      it 'returns nil for per_km when there are no odometer readings' do
        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:per_km]).to be_nil
      end

      it 'returns zero for per_trip when there are no trips' do
        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:per_trip]).to eq(0)
        expect(result[:metrics][:per_km]).to be_nil
        expect(result[:metrics][:margin]).to eq(0)
      end
    end

    context 'monthly_bars' do
      it 'delegates to BarsBuilder for the given year and month' do
        create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 300)
        create(:expense, user: user, date: Date.new(2025, 6, 5), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result[:monthly_bars]).to eq(Dashboard::BarsBuilder.new(user: user, year: 2025, month: 6).call)
      end
    end

    context 'categories' do
      it 'delegates to CategoryBreakdownService with limit 7' do
        %w[fuel maintenance car_wash toll parking documentation insurance fine].each_with_index do |category, index|
          create(:expense, user: user, date: Date.new(2025, 6, index + 1), amount: 100 - index, category: category, paid: true)
        end

        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result[:categories].size).to eq(7)
        expect(result[:categories].first[:id]).to eq('fuel')
      end
    end

    context 'platforms' do
      it 'delegates to PlatformBreakdownService with limit 5' do
        %w[uber ifood rappi shopee amazon nine_nine].each_with_index do |platform, index|
          create(:earning, user: user, date: Date.new(2025, 6, index + 1), amount: 100 - index, platform: platform)
        end

        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result[:platforms].size).to eq(5)
        expect(result[:platforms].first[:id]).to eq('uber')
      end
    end

    context 'platforms_total' do
      it 'returns the total earnings across every platform, not only the displayed rows' do
        %w[uber ifood rappi shopee amazon nine_nine].each_with_index do |platform, offset|
          create(:earning, user: user, date: Date.new(2025, 2, offset + 1), amount: 100, platform: platform)
        end

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:platforms].size).to eq(5)
        expect(result[:platforms_total]).to eq(600.0)
      end
    end

    context 'insights' do
      it 'emits the category with the highest amount of the period' do
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount: 300, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 2, 2), amount: 100, category: 'toll', paid: true)

        result = described_class.new(year: 2025, month: 2, user: user).call
        share = result[:insights].find { |insight| insight[:type] == 'category_share' }

        expect(share[:title]).to include('Combustível')
        expect(share[:title]).to include('75,0%')
      end

      it 'returns empty array when there is no data to analyze' do
        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:insights]).to eq([])
      end
    end

    context 'empty period' do
      it 'flags the period as empty and points to the last month with data' do
        create(:earning, user: user, date: Date.new(2024, 11, 3))

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:empty]).to be(true)
        expect(result[:last_month_with_data]).to eq(Date.new(2024, 11, 1))
      end

      it 'searches before January when the whole year is selected' do
        create(:earning, user: user, date: Date.new(2024, 12, 15))
        create(:earning, user: user, date: Date.new(2026, 1, 5))

        result = described_class.new(year: 2025, month: nil, user: user).call

        expect(result[:empty]).to be(true)
        expect(result[:last_month_with_data]).to eq(Date.new(2024, 12, 1))
      end

      it 'does not look for another month when the period has data' do
        create(:earning, user: user, date: Date.new(2025, 1, 10))
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount: 50, category: 'fuel', paid: true)
        allow(Dashboard::LastMonthWithData).to receive(:fetch)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:empty]).to be(false)
        expect(result[:last_month_with_data]).to be_nil
        expect(Dashboard::LastMonthWithData).not_to have_received(:fetch)
      end
    end
  end
end

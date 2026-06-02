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

    context 'monthly_bars' do
      it 'returns up to 5 most recent months that have earnings or expenses' do
        create(:earning, date: Date.new(2025, 1, 1), amount: 100)
        create(:earning, date: Date.new(2025, 3, 1), amount: 200)
        create(:earning, date: Date.new(2025, 4, 1), amount: 300)
        create(:expense, date: Date.new(2025, 5, 1), amount:  50, category: 'fuel', paid: true)
        create(:earning, date: Date.new(2025, 6, 1), amount: 400)
        create(:earning, date: Date.new(2025, 7, 1), amount: 500)
        create(:earning, date: Date.new(2025, 8, 1), amount: 600)

        result = described_class.new(year: 2025, month: nil).call

        expect(result[:monthly_bars].size).to eq(5)
        expect(result[:monthly_bars].map { |bar| bar[:month] }).to eq([4, 5, 6, 7, 8])
      end

      it 'maps each bar to earnings, expenses and translated label' do
        create(:earning, date: Date.new(2025, 6, 1), amount: 300)
        create(:expense, date: Date.new(2025, 6, 5), amount: 100, category: 'fuel', paid: true)

        bar = described_class.new(year: 2025, month: nil).call[:monthly_bars].first

        expect(bar[:earnings].to_f).to eq(300.0)
        expect(bar[:expenses].to_f).to eq(100.0)
        expect(bar[:label]).to eq(I18n.t('date.abbr_month_names')[6].capitalize)
      end

      it 'returns empty array when there is no activity in the year' do
        result = described_class.new(year: 2025, month: nil).call

        expect(result[:monthly_bars]).to eq([])
      end
    end

    context 'categories' do
      it 'delegates to CategoryBreakdownService with limit 7' do
        %w[fuel maintenance car_wash toll parking documentation insurance fine].each_with_index do |category, index|
          create(:expense, date: Date.new(2025, 6, index + 1), amount: 100 - index, category: category, paid: true)
        end

        result = described_class.new(year: 2025, month: 6).call

        expect(result[:categories].size).to eq(7)
        expect(result[:categories].first[:id]).to eq('fuel')
      end
    end

    context 'platforms' do
      it 'delegates to PlatformBreakdownService with limit 5' do
        %w[uber ifood rappi shopee amazon nine_nine].each_with_index do |platform, index|
          create(:earning, date: Date.new(2025, 6, index + 1), amount: 100 - index, platform: platform)
        end

        result = described_class.new(year: 2025, month: 6).call

        expect(result[:platforms].size).to eq(5)
        expect(result[:platforms].first[:id]).to eq('uber')
      end
    end
  end
end

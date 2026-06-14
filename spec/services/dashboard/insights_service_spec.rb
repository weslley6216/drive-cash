require 'rails_helper'

RSpec.describe Dashboard::InsightsService do
  let(:user) { create(:user) }

  describe '#call' do
    context 'metrics' do
      it 'returns per_day, per_trip, per_hour, margin and change_pct hash' do
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 800, trips_count: 10)
        create(:earning, user: user, date: Date.new(2025, 2, 5), amount: 200, trips_count: 10)
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount: 200, category: 'fuel', paid: true)
        create(:earning, user: user, date: Date.new(2025, 1, 1), amount: 600, trips_count: 20)
        create(:expense, user: user, date: Date.new(2025, 1, 1), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:per_day]).to eq(400.0)
        expect(result[:metrics][:per_trip].to_f.round(2)).to eq(40.0)
        expect(result[:metrics][:per_hour].to_f.round(2)).to eq(50.0)
        expect(result[:metrics][:margin]).to eq(80.0)
        expect(result[:metrics][:change_pct]).to be_a(Hash)
        expect(result[:metrics][:change_pct].keys).to match_array(%i[per_day per_trip per_hour margin])
      end

      it 'returns zero for per_trip when there are no trips' do
        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:per_trip]).to eq(0)
        expect(result[:metrics][:per_hour]).to eq(0)
        expect(result[:metrics][:margin]).to eq(0)
      end

      it 'returns nil for change_pct when previous period is empty' do
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:change_pct][:per_day]).to be_nil
      end

      it 'compares to previous year when month is nil' do
        create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 200, trips_count: 1)
        create(:earning, user: user, date: Date.new(2024, 6, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2025, month: nil, user: user).call

        expect(result[:metrics][:change_pct][:per_day]).to eq(100.0)
      end

      it 'applies YTD cutoff when year is current year and month is nil' do
        current_year = Date.current.year
        cutoff_month = Date.current.month

        create(:earning, user: user, date: Date.new(current_year, 1, 1), amount: 200, trips_count: 1)
        create(:earning, user: user, date: Date.new(current_year - 1, 1, 1), amount: 100, trips_count: 1)
        create(:earning, user: user, date: Date.new(current_year - 1, 12, 1), amount: 9999, trips_count: 1)

        result = described_class.new(year: current_year, month: nil, user: user).call

        if cutoff_month < 12
          expect(result[:metrics][:change_pct][:per_day]).to eq(100.0)
        else
          expect(result[:metrics][:change_pct][:per_day]).not_to be_nil
        end
      end

      it 'does not apply YTD cutoff for past years' do
        create(:earning, user: user, date: Date.new(2023, 1, 1), amount: 200, trips_count: 1)
        create(:earning, user: user, date: Date.new(2022, 12, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2023, month: nil, user: user).call

        expect(result[:metrics][:change_pct][:per_day]).to eq(100.0)
      end

      it 'compares to the previous month of the same year in monthly mode' do
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 200, trips_count: 1)
        create(:earning, user: user, date: Date.new(2025, 1, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:metrics][:change_pct][:per_day]).to eq(100.0)
      end

      it 'compares January to December of the previous year' do
        create(:earning, user: user, date: Date.new(2025, 1, 1), amount: 200, trips_count: 1)
        create(:earning, user: user, date: Date.new(2024, 12, 1), amount: 100, trips_count: 1)

        result = described_class.new(year: 2025, month: 1, user: user).call

        expect(result[:metrics][:change_pct][:per_day]).to eq(100.0)
      end
    end

    context 'monthly_bars' do
      it 'returns all 12 months when month is nil, marking months without data as empty' do
        create(:earning, user: user, date: Date.new(2025, 3, 1), amount: 200)
        create(:expense, user: user, date: Date.new(2025, 6, 1), amount: 50, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: nil, user: user).call

        expect(result[:monthly_bars].size).to eq(12)
        expect(result[:monthly_bars].map { |bar| bar[:key] }).to eq((1..12).to_a)

        march = result[:monthly_bars].find { |bar| bar[:key] == 3 }
        june  = result[:monthly_bars].find { |bar| bar[:key] == 6 }
        jan   = result[:monthly_bars].find { |bar| bar[:key] == 1 }

        expect(march[:empty]).to be false
        expect(june[:empty]).to be false
        expect(jan[:empty]).to be true
      end

      it 'returns annual bars with unit :month and i18n label' do
        create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 300)
        create(:expense, user: user, date: Date.new(2025, 6, 5), amount: 100, category: 'fuel', paid: true)

        bar = described_class.new(year: 2025, month: nil, user: user).call[:monthly_bars].find { |b| b[:key] == 6 }

        expect(bar[:unit]).to eq(:month)
        expect(bar[:earnings].to_f).to eq(300.0)
        expect(bar[:expenses].to_f).to eq(100.0)
        expect(bar[:label]).to eq(I18n.t('date.abbr_month_names')[6].capitalize)
      end

      it 'returns empty array when there is no activity in the year' do
        result = described_class.new(year: 2025, month: nil, user: user).call

        expect(result[:monthly_bars]).to eq([])
      end

      it 'returns daily bars when month is present, only days with data' do
        create(:earning, user: user, date: Date.new(2025, 6, 5),  amount: 200)
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 300)
        create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 50, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result[:monthly_bars].size).to eq(2)
        expect(result[:monthly_bars].map { |bar| bar[:key] }).to eq([5, 10])
      end

      it 'returns daily bars with unit :day and string label' do
        create(:earning, user: user, date: Date.new(2025, 6, 7), amount: 150)

        bar = described_class.new(year: 2025, month: 6, user: user).call[:monthly_bars].first

        expect(bar[:unit]).to eq(:day)
        expect(bar[:key]).to eq(7)
        expect(bar[:label]).to eq('7')
        expect(bar[:empty]).to be false
      end

      it 'returns empty array when month is present but no data exists' do
        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result[:monthly_bars]).to eq([])
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

    context 'period_context' do
      it 'returns mode :monthly with the previous month name and its year' do
        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result[:period_context][:mode]).to eq(:monthly)
        expect(result[:period_context][:previous_month_name]).to eq(I18n.t('date.abbr_month_names')[5])
        expect(result[:period_context][:previous_year]).to eq(2025)
      end

      it 'returns December of the previous year as previous period for January' do
        result = described_class.new(year: 2025, month: 1, user: user).call

        expect(result[:period_context][:previous_month_name]).to eq(I18n.t('date.abbr_month_names')[12])
        expect(result[:period_context][:previous_year]).to eq(2024)
      end

      it 'returns mode :annual with nil cutoff_month_name for past years' do
        result = described_class.new(year: 2024, month: nil, user: user).call

        expect(result[:period_context][:mode]).to eq(:annual)
        expect(result[:period_context][:cutoff_month_name]).to be_nil
        expect(result[:period_context][:previous_year]).to eq(2023)
      end

      it 'returns mode :annual with cutoff_month_name for current year' do
        result = described_class.new(year: Date.current.year, month: nil, user: user).call

        expect(result[:period_context][:mode]).to eq(:annual)
        expect(result[:period_context][:cutoff_month_name]).not_to be_nil
      end
    end

    it 'does not instantiate ProfitSeriesService for scalar comparisons' do
      create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 500, trips_count: 1)
      create(:earning, user: user, date: Date.new(2024, 6, 1), amount: 300, trips_count: 1)

      allow(Dashboard::ProfitSeriesService).to receive(:new).and_call_original

      described_class.new(year: 2025, month: 6, user: user).call

      expect(Dashboard::ProfitSeriesService).not_to have_received(:new)
    end

    it 'instantiates CategoryBreakdownService only once per call' do
      %w[fuel maintenance].each_with_index do |category, offset|
        create(:expense, user: user, date: Date.new(2025, 6, offset + 1), amount: 100, category: category, paid: true)
        create(:expense, user: user, date: Date.new(2024, 6, offset + 1), amount: 50,  category: category, paid: true)
      end

      allow(Dashboard::CategoryBreakdownService).to receive(:new).and_call_original

      described_class.new(year: 2025, month: 6, user: user).call

      expect(Dashboard::CategoryBreakdownService).to have_received(:new).once
    end

    it 'instantiates PlatformBreakdownService only once per call' do
      create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 500, trips_count: 1, platform: 'uber')
      create(:earning, user: user, date: Date.new(2025, 6, 2), amount: 50, trips_count: 5, platform: 'shopee')

      allow(Dashboard::PlatformBreakdownService).to receive(:new).and_call_original

      described_class.new(year: 2025, month: 6, user: user).call

      expect(Dashboard::PlatformBreakdownService).to have_received(:new).once
    end

    context 'insights' do
      it 'emits category_spike when top category grew more than 10 percent vs previous month' do
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount: 220, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 1, 1), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 2, user: user).call

        spike = result[:insights].find { |insight| insight[:type] == 'category_spike' }

        expect(spike).not_to be_nil
        expect(spike[:severity]).to eq('warning')
      end

      it 'category_spike uses description_monthly with current and previous month names' do
        create(:expense, user: user, date: Date.new(2025, 6, 1), amount: 220, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 5, 1), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 6, user: user).call
        spike  = result[:insights].find { |insight| insight[:type] == 'category_spike' }

        expect(spike[:description]).to include('junho')
        expect(spike[:description]).to include('maio')
      end

      it 'category_spike uses description_annual with previous year when month is nil' do
        create(:expense, user: user, date: Date.new(2025, 1, 1), amount: 220, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2024, 1, 1), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: nil, user: user).call
        spike  = result[:insights].find { |insight| insight[:type] == 'category_spike' }

        expect(spike[:description]).to include('2024')
        expect(spike[:description]).not_to include('mês anterior')
      end

      it 'emits best_day with the highest profit day of the month' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 500, trips_count: 1)
        create(:earning, user: user, date: Date.new(2025, 6, 15), amount: 200, trips_count: 1)

        result = described_class.new(year: 2025, month: 6, user: user).call
        best   = result[:insights].find { |insight| insight[:type] == 'best_day' }

        expect(best).not_to be_nil
        expect(best[:title]).to include('500,00')
      end

      it 'emits worst_platform when more than one platform has earnings in the period' do
        create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 500, trips_count: 1, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 6, 2), amount: 50, trips_count: 5, platform: 'shopee')

        result = described_class.new(year: 2025, month: 6, user: user).call
        worst  = result[:insights].find { |insight| insight[:type] == 'worst_platform' }

        expect(worst).not_to be_nil
        expect(worst[:title]).to include(I18n.t('activerecord.attributes.earning.platforms.shopee'))
      end

      it 'worst_platform reuses platforms breakdown trips_count for per-trip calculation' do
        create(:earning, user: user, date: Date.new(2025, 6, 1), amount: 500, trips_count: 10, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 6, 2), amount: 100, trips_count: 4,  platform: 'shopee')

        result = described_class.new(year: 2025, month: 6, user: user).call
        worst  = result[:insights].find { |insight| insight[:type] == 'worst_platform' }

        expect(worst).not_to be_nil
        expect(worst[:title]).to include(I18n.t('activerecord.attributes.earning.platforms.shopee'))
        expect(worst[:description]).to include('25,00')
      end

      it 'emits margin_drop with critical severity when margin fell more than 5 pp' do
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 1000)
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount: 900, category: 'fuel', paid: true)
        create(:earning, user: user, date: Date.new(2025, 1, 1), amount: 1000)
        create(:expense, user: user, date: Date.new(2025, 1, 1), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 2, user: user).call
        drop   = result[:insights].find { |insight| insight[:type] == 'margin_drop' }

        expect(drop).not_to be_nil
        expect(drop[:severity]).to eq('critical')
      end

      it 'returns at most 3 insights ordered by severity (critical first)' do
        create(:earning, user: user, date: Date.new(2025, 2, 1), amount: 1000, trips_count: 1, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 2, 2), amount:  50,  trips_count: 5, platform: 'shopee')
        create(:expense, user: user, date: Date.new(2025, 2, 1), amount:  900, category: 'fuel', paid: true)
        create(:earning, user: user, date: Date.new(2025, 1, 1), amount: 1000, trips_count: 1)
        create(:expense, user: user, date: Date.new(2025, 1, 1), amount: 100, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:insights].size).to be <= 3
        expect(result[:insights].first[:severity]).to eq('critical')
      end

      it 'returns empty array when there is no data to analyze' do
        result = described_class.new(year: 2025, month: 2, user: user).call

        expect(result[:insights]).to eq([])
      end
    end
  end
end

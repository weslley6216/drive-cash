require 'rails_helper'

RSpec.describe Dashboard::RecentActivityService do
  include ActiveSupport::Testing::TimeHelpers

  describe '#call' do
    context 'with month filter' do
      it 'merges earnings and expenses sorted by date desc' do
        earning = create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 3)
        expense1 = create(:expense, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)
        expense2 = create(:expense, date: Date.new(2025, 6, 5), amount: 30, category: 'meals', vendor: nil, description: 'Lanche', paid: true)

        result = described_class.new(year: 2025, month: 6).call

        expect(result.size).to eq(3)
        expect(result.first[:type]).to eq(:expense)
        expect(result.first[:date]).to eq(expense1.date)
        expect(result[1][:date]).to eq(earning.date)
        expect(result.last[:date]).to eq(expense2.date)
      end

      it 'limits to 5 rows by default' do
        7.times { |i| create(:earning, date: Date.new(2025, 6, 1) + i, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, month: 6).call

        expect(result.size).to eq(5)
      end

      it 'ignores expenses with paid: false' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 100, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: false)

        result = described_class.new(year: 2025, month: 6).call

        expect(result.size).to eq(1)
        expect(result.first[:type]).to eq(:earning)
      end

      it 'builds earning row with translated platform and trips description' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 4)

        row = described_class.new(year: 2025, month: 6).call.first

        expect(row[:type]).to eq(:earning)
        expect(row[:label]).to eq(I18n.t('activerecord.attributes.earning.platforms.uber'))
        expect(row[:description]).to eq(I18n.t('common.trips', count: 4))
        expect(row[:amount]).to eq(200.0)
      end

      it 'builds expense row with translated category and vendor description' do
        create(:expense, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)

        row = described_class.new(year: 2025, month: 6).call.first

        expect(row[:type]).to eq(:expense)
        expect(row[:label]).to eq(I18n.t('activerecord.attributes.expense.categories.fuel'))
        expect(row[:description]).to eq('Posto Shell')
      end

      it 'falls back to expense description when vendor is blank' do
        create(:expense, date: Date.new(2025, 6, 12), amount: 30, category: 'meals', vendor: nil, description: 'Lanche da tarde', paid: true)

        row = described_class.new(year: 2025, month: 6).call.first

        expect(row[:description]).to eq('Lanche da tarde')
      end

      it 'returns empty string description when vendor and description are blank' do
        create(:expense, date: Date.new(2025, 6, 12), amount: 30, category: 'other', vendor: nil, description: nil, paid: true)

        row = described_class.new(year: 2025, month: 6).call.first

        expect(row[:description]).to eq('')
      end
    end

    context 'with date labels' do
      it 'labels today as Hoje' do
        create(:earning, date: Date.current, amount: 100, platform: 'uber')

        row = described_class.new(year: Date.current.year, month: Date.current.month).call.first

        expect(row[:date_label]).to eq(I18n.t('common.today'))
      end

      it 'labels yesterday as Ontem' do
        travel_to Date.new(2026, 6, 15) do
          create(:earning, date: Date.current - 1, amount: 100, platform: 'uber')

          row = described_class.new(year: Date.current.year, month: Date.current.month).call.first

          expect(row[:date_label]).to eq(I18n.t('common.yesterday'))
        end
      end

      it 'labels other dates using :short format' do
        date = Date.new(2025, 6, 15)
        create(:earning, date: date, amount: 100, platform: 'uber')

        row = described_class.new(year: 2025, month: 6).call.first

        expect(row[:date_label]).to eq(I18n.l(date, format: :short))
      end
    end

    context 'without month filter' do
      it 'covers the whole year' do
        create(:earning, date: Date.new(2025, 1, 5), amount: 100, platform: 'uber')
        create(:earning, date: Date.new(2025, 12, 20), amount: 200, platform: 'ifood')

        result = described_class.new(year: 2025).call

        expect(result.size).to eq(2)
      end
    end

    context 'with custom limit' do
      it 'respects the limit argument' do
        4.times { |i| create(:earning, date: Date.new(2025, 6, 1) + i, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, month: 6, limit: 2).call

        expect(result.size).to eq(2)
      end
    end
  end
end

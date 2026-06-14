require 'rails_helper'

RSpec.describe Dashboard::RecentActivityService do
  let(:user) { create(:user) }

  describe '#call' do
    context 'with month filter' do
      it 'merges earnings and expenses sorted by date desc' do
        earning = create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 3)
        expense1 = create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)
        expense2 = create(:expense, user: user, date: Date.new(2025, 6, 5), amount: 30, category: 'meals', vendor: nil, description: 'Lanche', paid: true)

        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result.size).to eq(3)
        expect(result.first[:type]).to eq(:expense)
        expect(result.first[:date]).to eq(expense1.date)
        expect(result[1][:date]).to eq(earning.date)
        expect(result.last[:date]).to eq(expense2.date)
      end

      it 'limits to 5 rows by default' do
        7.times { |offset| create(:earning, user: user, date: Date.new(2025, 6, 1) + offset, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result.size).to eq(5)
      end

      it 'ignores expenses with paid: false' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 100, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: false)

        result = described_class.new(year: 2025, month: 6, user: user).call

        expect(result.size).to eq(1)
        expect(result.first[:type]).to eq(:earning)
      end

      it 'builds earning row with translated platform and trips description' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', trips_count: 4)

        row = described_class.new(year: 2025, month: 6, user: user).call.first

        expect(row[:type]).to eq(:earning)
        expect(row[:label]).to eq(I18n.t('activerecord.attributes.earning.platforms.uber'))
        expect(row[:description]).to eq(I18n.t('common.trips', count: 4))
        expect(row[:amount]).to eq(200.0)
      end

      it 'builds expense row with translated category and vendor description' do
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', vendor: 'Posto Shell', paid: true)

        row = described_class.new(year: 2025, month: 6, user: user).call.first

        expect(row[:type]).to eq(:expense)
        expect(row[:label]).to eq(I18n.t('activerecord.attributes.expense.categories.fuel'))
        expect(row[:description]).to eq('Posto Shell')
      end

      it 'falls back to expense description when vendor is blank' do
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 30, category: 'meals', vendor: nil, description: 'Lanche da tarde', paid: true)

        row = described_class.new(year: 2025, month: 6, user: user).call.first

        expect(row[:description]).to eq('Lanche da tarde')
      end

      it 'returns empty string description when vendor and description are blank' do
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 30, category: 'other', vendor: nil, description: nil, paid: true)

        row = described_class.new(year: 2025, month: 6, user: user).call.first

        expect(row[:description]).to eq('')
      end
    end

    context 'with date labels' do
      it 'labels the reference date as Hoje' do
        reference = Date.new(2026, 6, 15)
        create(:earning, user: user, date: reference, amount: 100, platform: 'uber')

        row = described_class.new(year: 2026, month: 6, user: user, date: reference).call.first

        expect(row[:date_label]).to eq(I18n.t('common.today'))
      end

      it 'labels the day before the reference date as Ontem' do
        reference = Date.new(2026, 6, 15)
        create(:earning, user: user, date: reference - 1, amount: 100, platform: 'uber')

        row = described_class.new(year: 2026, month: 6, user: user, date: reference).call.first

        expect(row[:date_label]).to eq(I18n.t('common.yesterday'))
      end

      it 'defaults the reference date to today' do
        create(:earning, user: user, date: Date.current, amount: 100, platform: 'uber')

        row = described_class.new(year: Date.current.year, month: Date.current.month, user: user).call.first

        expect(row[:date_label]).to eq(I18n.t('common.today'))
      end

      it 'labels other dates using :short format' do
        date = Date.new(2025, 6, 15)
        create(:earning, user: user, date: date, amount: 100, platform: 'uber')

        row = described_class.new(year: 2025, month: 6, user: user).call.first

        expect(row[:date_label]).to eq(I18n.l(date, format: :short))
      end
    end

    context 'without month filter' do
      it 'covers the whole year' do
        create(:earning, user: user, date: Date.new(2025, 1, 5), amount: 100, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 12, 20), amount: 200, platform: 'ifood')

        result = described_class.new(year: 2025, user: user).call

        expect(result.size).to eq(2)
      end
    end

    context 'with custom limit' do
      it 'respects the limit argument' do
        4.times { |offset| create(:earning, user: user, date: Date.new(2025, 6, 1) + offset, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, month: 6, limit: 2, user: user).call

        expect(result.size).to eq(2)
      end
    end
  end
end

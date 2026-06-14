require 'rails_helper'

RSpec.describe Dashboard::BarsBuilder do
  let(:user) { create(:user) }

  describe '#call' do
    context 'when month is nil (annual mode)' do
      it 'returns 12 entries with unit :month and capitalized abbr label' do
        create(:earning, user: user, date: Date.new(2025, 3, 1), amount: 200)
        create(:expense, user: user, date: Date.new(2025, 6, 1), amount: 50, category: 'fuel', paid: true)

        result = described_class.new(user: user, year: 2025, month: nil).call

        expect(result.size).to eq(12)
        expect(result.map { |bar| bar[:key] }).to eq((1..12).to_a)
        expect(result.first[:unit]).to eq(:month)
        expect(result.find { |bar| bar[:key] == 6 }[:label]).to eq(I18n.t('date.abbr_month_names')[6].capitalize)
      end

      it 'marks months without data as empty' do
        create(:earning, user: user, date: Date.new(2025, 3, 1), amount: 100)

        result = described_class.new(user: user, year: 2025, month: nil).call
        january = result.find { |bar| bar[:key] == 1 }
        march = result.find { |bar| bar[:key] == 3 }

        expect(january[:empty]).to be true
        expect(march[:empty]).to be false
      end

      it 'returns an empty array when there is no activity in the year' do
        result = described_class.new(user: user, year: 2025, month: nil).call

        expect(result).to eq([])
      end
    end

    context 'when month is present (daily mode)' do
      it 'returns one entry per day that has data with unit :day' do
        create(:earning, user: user, date: Date.new(2025, 6, 5), amount: 200)
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 300)
        create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 50, category: 'fuel', paid: true)

        result = described_class.new(user: user, year: 2025, month: 6).call

        expect(result.size).to eq(2)
        expect(result.map { |bar| bar[:key] }).to eq([5, 10])
        expect(result.first[:unit]).to eq(:day)
        expect(result.first[:label]).to eq('5')
        expect(result.first[:empty]).to be false
      end

      it 'returns an empty array when month has no data' do
        result = described_class.new(user: user, year: 2025, month: 6).call

        expect(result).to eq([])
      end
    end
  end
end

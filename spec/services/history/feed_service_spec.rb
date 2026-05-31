require 'rails_helper'

RSpec.describe History::FeedService do
  describe '#call' do
    context 'with no records in the period' do
      it 'returns empty groups and zeroed summary' do
        result = described_class.new(year: 2020).call

        expect(result[:groups]).to eq([])
        expect(result[:summary]).to eq(
          earnings: 0,
          expenses: 0,
          net: 0
        )
      end
    end

    context 'with filter all (default) and mixed records' do
      it 'groups items by date in descending order' do
        create(:earning, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber', trips_count: 3)
        create(:expense, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)
        create(:earning, date: Date.new(2025, 6, 10), amount: 150, platform: 'ifood', trips_count: 2)

        result = described_class.new(year: 2025).call

        dates = result[:groups].map { |group| group[:date] }
        expect(dates).to eq([Date.new(2025, 6, 12), Date.new(2025, 6, 10)])
      end

      it 'returns earnings_total and expenses_total per day' do
        create(:earning, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025).call

        first_day = result[:groups].first
        expect(first_day[:earnings_total]).to eq(200)
        expect(first_day[:expenses_total]).to eq(80)
      end

      it 'excludes records from other years' do
        create(:earning, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        expense_other_year = create(:expense, date: Date.new(2024, 12, 1), amount: 999, category: 'meals', paid: true)

        result = described_class.new(year: 2025).call

        ids = result[:groups].flat_map { |group| group[:items].map(&:id) }
        expect(ids).not_to include(expense_other_year.id)
      end

      it 'builds summary totals across all returned items' do
        create(:earning, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:earning, date: Date.new(2025, 6, 10), amount: 150, platform: 'ifood')
        create(:expense, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025).call

        expect(result[:summary][:earnings]).to eq(350)
        expect(result[:summary][:expenses]).to eq(80)
        expect(result[:summary][:net]).to eq(270)
      end

      it 'orders items within a day by created_at desc' do
        create(:earning, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025).call

        first_day_items = result[:groups].first[:items]
        expect(first_day_items.first.created_at).to be >= first_day_items.last.created_at
      end
    end

    context 'with month filter' do
      it 'restricts to the given month' do
        create(:earning, date: Date.new(2025, 3, 10), amount: 100, platform: 'uber')
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')

        result = described_class.new(year: 2025, month: 6).call

        amounts = result[:groups].flat_map { |group| group[:items].map(&:amount) }
        expect(amounts).to eq([200])
      end
    end

    context 'with limit smaller than total items' do
      it 'caps the combined collection' do
        5.times { |offset| create(:earning, date: Date.new(2025, 6, 1) + offset, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, limit: 3).call

        total_items = result[:groups].sum { |group| group[:items].size }
        expect(total_items).to eq(3)
      end

      it 'computes the summary from all matching items, not from the truncated set' do
        5.times { |offset| create(:earning, date: Date.new(2025, 6, 1) + offset, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, limit: 3).call

        expect(result[:summary][:earnings]).to eq(250)
      end
    end

    context 'with filter earnings' do
      it 'returns only earnings' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025, filter: 'earnings').call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:class).uniq).to eq([Earning])
      end

      it 'zeroes expenses in the summary' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025, filter: 'earnings').call

        expect(result[:summary]).to eq(earnings: 200, expenses: 0, net: 200)
      end
    end

    context 'with filter expenses' do
      it 'returns only expenses (including paid and unpaid)' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'expenses').call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:class).uniq).to eq([Expense])
        expect(items.size).to eq(2)
      end

      it 'zeroes earnings in the summary' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, filter: 'expenses').call

        expect(result[:summary]).to eq(earnings: 0, expenses: 80, net: -80)
      end
    end

    context 'with filter unpaid' do
      it 'returns only expenses with paid: false' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        unpaid = create(:expense, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'unpaid').call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([unpaid.id])
      end

      it 'never includes earnings in the unpaid view' do
        create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'unpaid').call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:class).uniq).to eq([Expense])
      end

      it 'summarizes only the unpaid amount' do
        create(:expense, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'unpaid').call

        expect(result[:summary]).to eq(earnings: 0, expenses: 40, net: -40)
      end
    end

    context 'with query parameter' do
      it 'matches expense vendor case-insensitive' do
        match    = create(:expense, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto Florense', paid: true)
        no_match = create(:expense, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

        result = described_class.new(year: 2025, query: 'orense').call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to include(match.id)
        expect(items.map(&:id)).not_to include(no_match.id)
      end

      it 'matches expense description case-insensitive' do
        match = create(:expense, date: Date.new(2025, 6, 10), amount: 30, category: 'meals', vendor: nil, description: 'Lanche da tarde', paid: true)
        create(:expense, date: Date.new(2025, 6, 11), amount: 40, category: 'fuel', vendor: 'Posto X', paid: true)

        result = described_class.new(year: 2025, query: 'lanche').call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([match.id])
      end

      it 'matches earning notes case-insensitive' do
        match = create(:earning, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', notes: 'Madrugada produtiva')
        create(:earning, date: Date.new(2025, 6, 11), amount: 100, platform: 'ifood', notes: 'Tarde calma')

        result = described_class.new(year: 2025, query: 'madru').call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([match.id])
      end

      it 'returns empty groups when nothing matches' do
        create(:expense, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto X', paid: true)
        create(:earning, date: Date.new(2025, 6, 11), amount: 100, platform: 'uber', notes: 'normal')

        result = described_class.new(year: 2025, query: 'inexistente').call

        expect(result[:groups]).to eq([])
        expect(result[:summary]).to eq(earnings: 0, expenses: 0, net: 0)
      end
    end
  end
end

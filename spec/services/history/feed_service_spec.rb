require 'rails_helper'

RSpec.describe History::FeedService do
  let(:user) { create(:user) }

  describe '#call' do
    context 'with no records in the period' do
      it 'returns empty groups and zeroed summary' do
        result = described_class.new(year: 2020, user: user).call

        expect(result[:groups]).to eq([])
        expect(result[:summary]).to eq(earnings: 0, expenses: 0, net: 0)
      end
    end

    context 'with filter all (default) and mixed records' do
      it 'groups items by date in descending order' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber', trips_count: 3)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 150, platform: 'ifood', trips_count: 2)

        result = described_class.new(year: 2025, user: user).call

        dates = result[:groups].map { |group| group[:date] }
        expect(dates).to eq([Date.new(2025, 6, 12), Date.new(2025, 6, 10)])
      end

      it 'returns earnings_total and expenses_total per day' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025, user: user).call

        first_day = result[:groups].first
        expect(first_day[:earnings_total]).to eq(200)
        expect(first_day[:expenses_total]).to eq(80)
      end

      it 'excludes records from other years' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        expense_other_year = create(:expense, user: user, date: Date.new(2024, 12, 1), amount: 999, category: 'meals', paid: true)

        result = described_class.new(year: 2025, user: user).call

        ids = result[:groups].flat_map { |group| group[:items].map(&:id) }
        expect(ids).not_to include(expense_other_year.id)
      end

      it 'builds summary totals across all returned items' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 150, platform: 'ifood')
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025, user: user).call

        expect(result[:summary][:earnings]).to eq(350)
        expect(result[:summary][:expenses]).to eq(80)
        expect(result[:summary][:net]).to eq(270)
      end

      it 'orders items within a day by created_at desc' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025, user: user).call

        first_day_items = result[:groups].first[:items]
        expect(first_day_items.first.created_at).to be >= first_day_items.last.created_at
      end

      it 'excludes unpaid expenses from the feed' do
        paid = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, user: user).call

        ids = result[:groups].flat_map { |group| group[:items].map(&:id) }
        expect(ids).to eq([paid.id])
      end
    end

    context 'with month filter' do
      it 'restricts to the given month' do
        create(:earning, user: user, date: Date.new(2025, 3, 10), amount: 100, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')

        result = described_class.new(year: 2025, month: 6, user: user).call

        amounts = result[:groups].flat_map { |group| group[:items].map(&:amount) }
        expect(amounts).to eq([200])
      end
    end

    context 'with limit smaller than total items' do
      it 'caps the combined collection' do
        5.times { |offset| create(:earning, user: user, date: Date.new(2025, 6, 1) + offset, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, limit: 3, user: user).call

        total_items = result[:groups].sum { |group| group[:items].size }
        expect(total_items).to eq(3)
      end

      it 'computes the summary from all matching items, not from the truncated set' do
        5.times { |offset| create(:earning, user: user, date: Date.new(2025, 6, 1) + offset, amount: 50, platform: 'uber') }

        result = described_class.new(year: 2025, limit: 3, user: user).call

        expect(result[:summary][:earnings]).to eq(250)
      end
    end

    context 'with filter earnings' do
      it 'returns only earnings' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025, filter: 'earnings', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:class).uniq).to eq([Earning])
      end

      it 'still includes expenses in the summary regardless of chip filter' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80,  category: 'fuel', paid: true)

        result = described_class.new(year: 2025, filter: 'earnings', user: user).call

        expect(result[:summary]).to eq(earnings: 200, expenses: 80, net: 120)
      end
    end

    context 'with filter expenses' do
      it 'returns only paid expenses' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        paid = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'expenses', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([paid.id])
      end

      it 'still includes earnings in the summary regardless of chip filter' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, filter: 'expenses', user: user).call

        expect(result[:summary]).to eq(earnings: 200, expenses: 80, net: 120)
      end
    end

    context 'with filter unpaid' do
      it 'returns only expenses with paid: false' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        unpaid = create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'unpaid', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([unpaid.id])
      end

      it 'never includes earnings in the unpaid view' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'unpaid', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:class).uniq).to eq([Expense])
      end

      it 'computes summary excluding unpaid expenses' do
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, filter: 'unpaid', user: user).call

        expect(result[:summary]).to eq(earnings: 0, expenses: 80, net: -80)
      end
    end

    context 'with query parameter' do
      it 'matches expense vendor case-insensitive' do
        match    = create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto Florense', paid: true)
        no_match = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

        result = described_class.new(year: 2025, query: 'orense', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to include(match.id)
        expect(items.map(&:id)).not_to include(no_match.id)
      end

      it 'matches expense description case-insensitive' do
        match = create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 30, category: 'meals', vendor: nil, description: 'Lanche da tarde', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'fuel', vendor: 'Posto X', paid: true)

        result = described_class.new(year: 2025, query: 'lanche', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([match.id])
      end

      it 'matches earning notes case-insensitive' do
        match = create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber', notes: 'Madrugada produtiva')
        create(:earning, user: user, date: Date.new(2025, 6, 11), amount: 100, platform: 'ifood', notes: 'Tarde calma')

        result = described_class.new(year: 2025, query: 'madru', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([match.id])
      end

      it 'returns empty groups when nothing matches but keeps full-period summary' do
        create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto X', paid: true)
        create(:earning, user: user, date: Date.new(2025, 6, 11), amount: 100, platform: 'uber', notes: 'normal')

        result = described_class.new(year: 2025, query: 'inexistente', user: user).call

        expect(result[:groups]).to eq([])
        expect(result[:summary]).to eq(earnings: 100, expenses: 80, net: 20)
      end
    end
  end
end

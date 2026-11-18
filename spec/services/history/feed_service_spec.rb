require 'rails_helper'

RSpec.describe History::FeedService do
  let(:user) { create(:user) }

  describe '#call' do
    context 'with no records in the period' do
      it 'returns empty groups, zeroed summary, no count and no next page' do
        result = described_class.new(year: 2020, user: user).call

        expect(result[:groups]).to eq([])
        expect(result[:summary]).to eq(earnings: 0, expenses: 0, net: 0)
        expect(result[:total_count]).to eq(0)
        expect(result[:next_page]).to be_nil
      end
    end

    context 'with filter all (default) and mixed records' do
      it 'groups items by date in descending order' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber', trips_count: 3)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', paid: true)
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 150, platform: 'ifood', trips_count: 2)

        result = described_class.new(year: 2025, user: user).call

        dates = result[:groups].map { |group| group[:date] }
        expect(dates).to eq([Date.new(2025, 6, 12), Date.new(2025, 6, 10)])
      end

      it 'returns earnings_total and expenses_total per day' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', paid: true)

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
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, user: user).call

        expect(result[:summary][:earnings]).to eq(350)
        expect(result[:summary][:expenses]).to eq(80)
        expect(result[:summary][:net]).to eq(270)
      end

      it 'orders items within a day by created_at desc' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, user: user).call

        first_day_items = result[:groups].first[:items]
        expect(first_day_items.first.created_at).to be >= first_day_items.last.created_at
      end

      it 'lists unpaid expenses alongside the paid ones' do
        paid = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        unpaid = create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, user: user).call

        ids = result[:groups].flat_map { |group| group[:items].map(&:id) }
        expect(ids).to eq([unpaid.id, paid.id])
      end

      it 'sums unpaid expenses into the expenses total but keeps them out of the net' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, user: user).call

        expect(result[:summary]).to eq(earnings: 200, expenses: 120, net: 120)
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

    context 'with pagination' do
      before { stub_const('History::FeedService::PER_PAGE', 2) }

      def create_five_days
        5.times { |offset| create(:earning, user: user, date: Date.new(2025, 6, 1) + offset, amount: 50, platform: 'uber') }
      end

      it 'loads one page of the newest records and points to the next page' do
        create_five_days

        result = described_class.new(year: 2025, user: user).call

        expect(result[:groups].map { |group| group[:date] }).to eq([Date.new(2025, 6, 5), Date.new(2025, 6, 4)])
        expect(result[:next_page]).to eq(2)
      end

      it 'accumulates the previous pages when a later page is requested' do
        create_five_days

        result = described_class.new(year: 2025, page: 2, user: user).call

        expect(result[:groups].sum { |group| group[:items].size }).to eq(4)
        expect(result[:next_page]).to eq(3)
      end

      it 'has no next page once every record is loaded' do
        create_five_days

        result = described_class.new(year: 2025, page: 3, user: user).call

        expect(result[:groups].sum { |group| group[:items].size }).to eq(5)
        expect(result[:next_page]).to be_nil
      end

      it 'completes the last day instead of splitting it across pages' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', paid: false)
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 150, platform: 'ifood')

        result = described_class.new(year: 2025, user: user).call

        last_day = result[:groups].last
        expect(last_day[:date]).to eq(Date.new(2025, 6, 11))
        expect(last_day[:expenses_total]).to eq(120)
        expect(result[:next_page]).to eq(2)
      end

      it 'counts every record of the filter in the period, not only the loaded page' do
        create_five_days
        create(:expense, user: user, date: Date.new(2025, 6, 3), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, slice: History::Slice.preset('earnings'), user: user).call

        expect(result[:total_count]).to eq(5)
      end

      it 'counts only the records matching the search' do
        create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto Florense', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

        result = described_class.new(year: 2025, query: 'orense', user: user).call

        expect(result[:total_count]).to eq(1)
      end

      it 'computes the summary from all matching items, not from the loaded page' do
        create_five_days

        result = described_class.new(year: 2025, user: user).call

        expect(result[:summary][:earnings]).to eq(250)
      end
    end

    context 'aggregation contract' do
      it 'returns the same summary numbers regardless of page' do
        stub_const('History::FeedService::PER_PAGE', 1)
        create(:earning, user: user, date: Date.new(2025, 1, 5), amount: 100, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 3, 5), amount: 50, platform: 'ifood')
        create(:expense, user: user, date: Date.new(2025, 6, 1), amount: 30, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 7, 1), amount: 70, category: 'meals', paid: false)

        first = described_class.new(year: 2025, user: user).call
        full = described_class.new(year: 2025, page: 999, user: user).call

        expect(first[:summary]).to eq(full[:summary])
        expect(first[:summary]).to eq(earnings: 150, expenses: 100, net: 120)
      end
    end

    context 'with records of another user' do
      it 'keeps them out of the feed, the count and the summary' do
        mine = create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        other = create(:user)
        create(:earning, user: other, date: Date.new(2025, 6, 10), amount: 500, platform: 'uber')
        create(:expense, user: other, date: Date.new(2025, 6, 11), amount: 90, category: 'fuel', paid: false)

        result = described_class.new(year: 2025, user: user).call

        expect(result[:groups].flat_map { |group| group[:items].map(&:id) }).to eq([mine.id])
        expect(result[:total_count]).to eq(1)
        expect(result[:summary]).to eq(earnings: 200, expenses: 0, net: 200)
      end
    end

    context 'with the earnings preset' do
      it 'returns only earnings' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, slice: History::Slice.preset('earnings'), user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:class).uniq).to eq([Earning])
      end

      it 'still includes expenses in the summary regardless of chip filter' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, slice: History::Slice.preset('earnings'), user: user).call

        expect(result[:summary]).to eq(earnings: 200, expenses: 80, net: 120)
      end
    end

    context 'with the expenses preset' do
      it 'returns the paid and the unpaid expenses' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        paid = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        unpaid = create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, slice: History::Slice.preset('expenses'), user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([unpaid.id, paid.id])
      end

      it 'still includes earnings in the summary regardless of chip filter' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, slice: History::Slice.preset('expenses'), user: user).call

        expect(result[:summary]).to eq(earnings: 200, expenses: 80, net: 120)
      end
    end

    context 'with the unpaid preset' do
      it 'returns only expenses with paid: false' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        unpaid = create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, slice: History::Slice.preset('unpaid'), user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([unpaid.id])
      end

      it 'never includes earnings in the unpaid view' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, slice: History::Slice.preset('unpaid'), user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:class).uniq).to eq([Expense])
      end

      it 'sums the unpaid expenses into the expenses total and keeps the net on the paid ones' do
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, slice: History::Slice.preset('unpaid'), user: user).call

        expect(result[:summary]).to eq(earnings: 0, expenses: 120, net: -80)
      end
    end

    context 'with a category slice' do
      it 'returns the paid and unpaid expenses of that category in the period' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        fuel = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        unpaid_fuel = create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 30, category: 'fuel', paid: false)
        create(:expense, user: user, date: Date.new(2025, 6, 13), amount: 40, category: 'meals', paid: true)
        create(:expense, user: user, date: Date.new(2025, 7, 11), amount: 90, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, month: 6, slice: History::Slice.new(categories: %w[fuel]), user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to eq([unpaid_fuel.id, fuel.id])
      end

      it 'keeps the summary of the whole period regardless of the slice' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 13), amount: 40, category: 'meals', paid: true)

        result = described_class.new(year: 2025, month: 6, slice: History::Slice.new(categories: %w[fuel]), user: user).call

        expect(result[:summary]).to eq(earnings: 200, expenses: 120, net: 80)
      end

      it 'returns only the expenses of the marked vendor and counts them' do
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 200, platform: 'uber')
        orense = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Orense', paid: true)
        create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 70, category: 'fuel', vendor: 'Shell', paid: true)
        slice = History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] })

        result = described_class.new(year: 2025, month: 6, slice: slice, user: user).call

        expect(result[:groups].flat_map { |group| group[:items].map(&:id) }).to eq([orense.id])
        expect(result[:total_count]).to eq(1)
      end

      it 'keeps the slice inside the user records' do
        create(:expense, user: create(:user), date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Orense', paid: true)
        mine = create(:expense, user: user, date: Date.new(2025, 6, 12), amount: 60, category: 'fuel', vendor: 'Posto Orense', paid: true)
        slice = History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] })

        result = described_class.new(year: 2025, month: 6, slice: slice, user: user).call

        expect(result[:groups].flat_map { |group| group[:items].map(&:id) }).to eq([mine.id])
      end

      it 'returns the facets of the whole period for the filter panel, whatever the slice' do
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Orense', paid: true)

        result = described_class.new(year: 2025, month: 6, slice: History::Slice.new(platforms: %w[uber]), user: user).call

        expect(result[:facets][:categories]).to eq('fuel' => { count: 1, total: 80 })
      end
    end

    context 'with the slice summary and the band' do
      it 'leaves both out without a marked level' do
        result = described_class.new(year: 2025, month: 6, slice: History::Slice.preset('expenses'), user: user).call

        expect(result[:slice_summary]).to be_nil
        expect(result[:trend]).to be_nil
      end

      it 'summarizes the slice and returns its six month band' do
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', vendor: 'Posto Orense', paid: true)

        result = described_class.new(year: 2025, month: 6, slice: History::Slice.new(categories: %w[fuel]), user: user).call

        expect(result[:slice_summary]).to include(kind: :expenses, total: 80, count: 1)
        expect(result[:trend][:months].last).to eq(year: 2025, month: 6, total: 80)
      end
    end

    context 'in the twelve month mode' do
      before { travel_to Time.zone.local(2026, 5, 22, 10, 0) }

      it 'returns the twelve month breakdown and its count instead of the day groups' do
        create(:expense, user: user, date: Date.new(2025, 9, 10), amount: 189.9, category: 'insurance', paid: true)
        create(:expense, user: user, date: Date.new(2026, 5, 10), amount: 214.3, category: 'insurance', paid: true)
        slice = History::Slice.new(categories: %w[insurance], range: '12m')

        result = described_class.new(year: 2026, slice: slice, user: user).call

        expect(result[:twelve_months]).to include(total: 404.2, count: 2)
        expect(result[:total_count]).to eq(2)
        expect(result[:groups]).to eq([])
        expect(result[:next_page]).to be_nil
        expect(result[:facets][:categories]).to eq('insurance' => { count: 1, total: 214.3 })
      end
    end

    context 'with query parameter' do
      it 'delegates matching to RecordSearch for both earnings and expenses' do
        match = create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto Florense', paid: true)
        no_match = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', vendor: 'Lanchonete', paid: true)

        result = described_class.new(year: 2025, query: 'orense', user: user).call

        items = result[:groups].flat_map { |group| group[:items] }
        expect(items.map(&:id)).to include(match.id)
        expect(items.map(&:id)).not_to include(no_match.id)
      end

      it 'returns empty groups when nothing matches but keeps full-period summary' do
        create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 80, category: 'fuel', vendor: 'Posto X', paid: true)
        create(:earning, user: user, date: Date.new(2025, 6, 11), amount: 100, platform: 'uber', notes: 'normal')

        result = described_class.new(year: 2025, query: 'inexistente', user: user).call

        expect(result[:groups]).to eq([])
        expect(result[:summary]).to eq(earnings: 100, expenses: 80, net: 20)
      end
    end

    context 'with focus_day' do
      it 'inserts an empty gap group for the focused day in date order' do
        create(:earning, user: user, date: Date.new(2025, 6, 12), amount: 200, platform: 'uber')
        create(:earning, user: user, date: Date.new(2025, 6, 10), amount: 150, platform: 'ifood')

        result = described_class.new(year: 2025, focus_day: Date.new(2025, 6, 11), user: user).call

        expect(result[:groups].map { |group| group[:date] }).to eq([Date.new(2025, 6, 12), Date.new(2025, 6, 11), Date.new(2025, 6, 10)])
        expect(result[:groups].second).to eq(date: Date.new(2025, 6, 11), items: [], gap: true)
      end

      it 'does not insert the gap when the day has a visible record' do
        create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 80, category: 'fuel', paid: true)

        result = described_class.new(year: 2025, focus_day: Date.new(2025, 6, 11), user: user).call

        expect(result[:groups].size).to eq(1)
        expect(result[:groups].first).not_to have_key(:gap)
      end

      it 'does not insert the gap when the day only has an unpaid expense' do
        unpaid = create(:expense, user: user, date: Date.new(2025, 6, 11), amount: 40, category: 'meals', paid: false)

        result = described_class.new(year: 2025, focus_day: Date.new(2025, 6, 11), user: user).call

        expect(result[:groups].size).to eq(1)
        expect(result[:groups].first[:items].map(&:id)).to eq([unpaid.id])
      end

      it 'does not insert the gap when the day has an earning' do
        create(:earning, user: user, date: Date.new(2025, 6, 11), amount: 200, platform: 'uber')

        result = described_class.new(year: 2025, focus_day: Date.new(2025, 6, 11), user: user).call

        expect(result[:groups].size).to eq(1)
        expect(result[:groups].first[:items].size).to eq(1)
      end

      it 'does not treat the day as logged because of another user earning on the same date' do
        create(:earning, user: create(:user), date: Date.new(2025, 6, 11), amount: 200, platform: 'uber')

        result = described_class.new(year: 2025, focus_day: Date.new(2025, 6, 11), user: user).call

        expect(result[:groups]).to eq([{ date: Date.new(2025, 6, 11), items: [], gap: true }])
      end
    end
  end
end

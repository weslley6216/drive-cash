require 'rails_helper'

RSpec.describe History::SliceMonthlyTotals do
  let(:user) { create(:user) }
  let(:period) { Date.new(2026, 1, 1)..Date.new(2026, 3, 31) }

  def totals_for(slice, query: nil) = described_class.new(slice: slice, user: user, period: period, query: query).call

  it 'sums and counts the user expenses of the slice in each month of the period' do
    create(:expense, user: user, date: Date.new(2026, 1, 10), amount: 189.9, category: 'insurance')
    create(:expense, user: user, date: Date.new(2026, 3, 5), amount: 100, category: 'insurance')
    create(:expense, user: user, date: Date.new(2026, 3, 25), amount: 114.3, category: 'insurance')
    create(:expense, user: user, date: Date.new(2026, 4, 1), amount: 999, category: 'insurance')
    create(:expense, user: user, date: Date.new(2026, 2, 10), amount: 50, category: 'fuel')
    create(:expense, user: create(:user), date: Date.new(2026, 2, 10), amount: 300, category: 'insurance')

    expect(totals_for(History::Slice.new(categories: %w[insurance]))).to eq(
      [2026, 1] => { total: 189.9, count: 1 }, [2026, 3] => { total: 214.3, count: 2 }
    )
  end

  it 'sums the earnings of a platform slice' do
    create(:earning, user: user, date: Date.new(2026, 2, 3), amount: 32.5, platform: 'uber')
    create(:earning, user: user, date: Date.new(2026, 2, 4), amount: 40, platform: 'nine_nine')

    expect(totals_for(History::Slice.new(platforms: %w[uber]))).to eq([2026, 2] => { total: 32.5, count: 1 })
  end

  it 'aggregates only the records that match the search' do
    create(:expense, user: user, date: Date.new(2026, 1, 10), amount: 189.9, category: 'insurance', vendor: 'Porto Seguro')
    create(:expense, user: user, date: Date.new(2026, 1, 12), amount: 20, category: 'insurance', vendor: 'Despachante')

    expect(totals_for(History::Slice.new(categories: %w[insurance]), query: 'porto')).to eq([2026, 1] => { total: 189.9, count: 1 })
  end
end

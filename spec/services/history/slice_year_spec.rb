require 'rails_helper'

RSpec.describe History::SliceYear do
  let(:user) { create(:user) }

  before { travel_to Time.zone.local(2026, 5, 22, 10, 0) }

  def year_for(slice, query: nil) = described_class.new(slice: slice, user: user, query: query).call

  it 'breaks the twelve months ending in the current one down by month' do
    create(:expense, user: user, date: Date.new(2025, 5, 31), amount: 999, category: 'insurance', vendor: 'Porto Seguro')
    create(:expense, user: user, date: Date.new(2025, 6, 10), amount: 189.9, category: 'insurance', vendor: 'Porto Seguro')
    create(:expense, user: user, date: Date.new(2026, 5, 10), amount: 214.3, category: 'insurance', vendor: 'Porto Seguro')

    result = year_for(History::Slice.new(categories: %w[insurance], range: '12m'))

    expect(result).to include(kind: :expenses, series: 'insurance', total: 404.2, count: 2)
    expect(result[:months].first).to eq(year: 2025, month: 6, total: 189.9, count: 1)
    expect(result[:months].last).to eq(year: 2026, month: 5, total: 214.3, count: 1)
  end

  it 'attaches the latest record of each listed month for its icon and description' do
    create(:expense, user: user, date: Date.new(2026, 4, 2), amount: 30, category: 'fuel', vendor: 'Shell')
    latest = create(:expense, user: user, date: Date.new(2026, 4, 20), amount: 60, category: 'fuel', vendor: 'Posto Orense')
    single = create(:expense, user: user, date: Date.new(2026, 5, 3), amount: 50, category: 'fuel', vendor: 'Posto Orense')

    rows = year_for(History::Slice.new(categories: %w[fuel], range: '12m'))[:rows]

    expect(rows.map { |row| [row[:month], row[:count], row[:record]] }).to eq([[5, 1, single], [4, 2, latest]])
  end

  it 'aggregates only what the search finds, inside the user records' do
    create(:expense, user: user, date: Date.new(2026, 5, 3), amount: 50, category: 'fuel', vendor: 'Posto Orense')
    create(:expense, user: user, date: Date.new(2026, 5, 4), amount: 70, category: 'fuel', vendor: 'Shell')
    create(:expense, user: create(:user), date: Date.new(2026, 5, 5), amount: 80, category: 'fuel', vendor: 'Posto Orense')

    result = year_for(History::Slice.new(categories: %w[fuel], range: '12m'), query: 'orense')

    expect(result).to include(total: 50.0, count: 1)
  end

  it 'sums a platform slice as earnings' do
    create(:earning, user: user, date: Date.new(2026, 5, 3), amount: 32.5, platform: 'uber')

    expect(year_for(History::Slice.new(platforms: %w[uber], range: '12m'))).to include(kind: :earnings, series: 'uber', total: 32.5)
  end

  it 'has nothing to break down outside the twelve month mode' do
    expect(year_for(History::Slice.new(categories: %w[fuel]))).to be_nil
  end
end

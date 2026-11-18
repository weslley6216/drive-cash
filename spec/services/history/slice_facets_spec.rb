require 'rails_helper'

RSpec.describe History::SliceFacets do
  let(:user) { create(:user) }

  def facets(query: nil) = described_class.new(user: user, year: 2026, month: 5, query: query).call

  before do
    create(:earning, user: user, date: Date.new(2026, 5, 22), amount: 32.5, platform: 'uber')
    create(:earning, user: user, date: Date.new(2026, 5, 21), amount: 18, platform: 'uber')
    create(:expense, user: user, date: Date.new(2026, 5, 22), amount: 60, category: 'fuel', vendor: 'Posto Orense', paid: true)
    create(:expense, user: user, date: Date.new(2026, 5, 19), amount: 65, category: 'fuel', vendor: 'Posto Orense', paid: false)
    create(:expense, user: user, date: Date.new(2026, 5, 18), amount: 70, category: 'fuel', vendor: 'Shell', paid: true)
    create(:expense, user: user, date: Date.new(2026, 5, 20), amount: 35, category: 'car_wash', vendor: nil, paid: true)
    create(:expense, user: user, date: Date.new(2026, 5, 20), amount: 15, category: 'car_wash', vendor: '', paid: true)
    create(:expense, user: user, date: Date.new(2026, 4, 30), amount: 99, category: 'fuel', vendor: 'Posto Orense', paid: true)
    create(:expense, user: create(:user), date: Date.new(2026, 5, 22), amount: 50, category: 'fuel', vendor: 'Posto Orense', paid: true)
  end

  it 'counts the earnings and the expenses of the period for the type level' do
    expect(facets).to include(earnings_count: 2, expenses_count: 5)
  end

  it 'counts and sums each platform and each category that has records' do
    expect(facets[:platforms]).to eq('uber' => { count: 2, total: 50.5 })
    expect(facets[:categories]).to eq('fuel' => { count: 3, total: 195 }, 'car_wash' => { count: 2, total: 50 })
  end

  it 'lists the vendors of each category by count, with the vendorless ones merged and last' do
    expect(facets[:vendors]).to eq(
      'fuel'     => [{ vendor: 'Posto Orense', count: 2, total: 125 }, { vendor: 'Shell', count: 1, total: 70 }],
      'car_wash' => [{ vendor: History::Slice::NO_VENDOR, count: 2, total: 50 }]
    )
  end

  it 'breaks the expenses down by category, vendor and payment for the live footer count' do
    expect(facets[:rows]).to contain_exactly(
      { type: 'earnings', platform: 'uber', count: 2 },
      { type: 'expenses', category: 'fuel', vendor: 'Posto Orense', paid: true, count: 1 },
      { type: 'expenses', category: 'fuel', vendor: 'Posto Orense', paid: false, count: 1 },
      { type: 'expenses', category: 'fuel', vendor: 'Shell', paid: true, count: 1 },
      { type: 'expenses', category: 'car_wash', vendor: History::Slice::NO_VENDOR, paid: true, count: 2 }
    )
  end

  it 'counts only the records matching the search' do
    expect(facets(query: 'orense')).to include(earnings_count: 0, expenses_count: 2)
  end
end

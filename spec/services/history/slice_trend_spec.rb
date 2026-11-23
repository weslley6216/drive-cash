require 'rails_helper'

RSpec.describe History::SliceTrend do
  let(:user) { create(:user) }

  before { travel_to Time.zone.local(2026, 6, 10, 10, 0) }

  it 'totals the slice in each of the six months ending at the selected one and compares the last two' do
    create(:expense, user: user, date: Date.new(2026, 5, 22), amount: 60, category: 'fuel', vendor: 'Posto Orense')
    create(:expense, user: user, date: Date.new(2026, 5, 19), amount: 65, category: 'fuel', vendor: 'Posto Orense')
    create(:expense, user: user, date: Date.new(2026, 4, 16), amount: 100, category: 'fuel', vendor: 'Posto Orense')
    create(:expense, user: user, date: Date.new(2025, 12, 2), amount: 80, category: 'fuel', vendor: 'Posto Orense')
    create(:expense, user: user, date: Date.new(2025, 11, 30), amount: 999, category: 'fuel', vendor: 'Posto Orense')
    create(:expense, user: user, date: Date.new(2026, 5, 20), amount: 70, category: 'fuel', vendor: 'Shell')
    create(:expense, user: create(:user), date: Date.new(2026, 5, 20), amount: 300, category: 'fuel', vendor: 'Posto Orense')

    trend = described_class.new(slice: History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] }), user: user,
                                year: 2026, month: 5).call

    expect(trend[:kind]).to eq(:expenses)
    expect(trend[:months]).to eq([
      { year: 2025, month: 12, total: 80 }, { year: 2026, month: 1, total: 0 }, { year: 2026, month: 2, total: 0 },
      { year: 2026, month: 3, total: 0 }, { year: 2026, month: 4, total: 100 }, { year: 2026, month: 5, total: 125 }
    ])
    expect(trend[:change]).to eq(25.0)
    expect(trend[:in_progress]).to be(false)
  end

  it 'flags the current month as in progress and has no change without a previous total' do
    create(:earning, user: user, date: Date.new(2026, 6, 2), amount: 32.5, platform: 'uber')

    trend = described_class.new(slice: History::Slice.new(platforms: %w[uber]), user: user, year: 2026, month: 6).call

    expect(trend[:kind]).to eq(:earnings)
    expect(trend[:months].last).to eq(year: 2026, month: 6, total: 32.5)
    expect(trend[:change]).to be_nil
    expect(trend[:in_progress]).to be(true)
  end

  it 'has no band for a slice of more than one series or for the whole year' do
    expect(described_class.new(slice: History::Slice.new(categories: %w[fuel car_wash]), user: user, year: 2026, month: 5).call).to be_nil
    expect(described_class.new(slice: History::Slice.new(categories: %w[fuel]), user: user, year: 2026, month: nil).call).to be_nil
  end
end

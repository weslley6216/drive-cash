require 'rails_helper'

RSpec.describe History::SliceSummary do
  let(:user) { create(:user) }

  def summary_for(slice) = described_class.new(slice: slice, user: user, year: 2026, month: 5).call

  before do
    create(:earning, user: user, date: Date.new(2026, 5, 22), amount: 32.5, platform: 'uber')
    create(:earning, user: user, date: Date.new(2026, 5, 21), amount: 18, platform: 'uber')
    create(:earning, user: user, date: Date.new(2026, 5, 21), amount: 41.5, platform: 'nine_nine')
    create(:expense, user: user, date: Date.new(2026, 5, 22), amount: 60, category: 'fuel', vendor: 'Posto Orense', paid: true)
    create(:expense, user: user, date: Date.new(2026, 5, 19), amount: 65, category: 'fuel', vendor: 'Posto Orense', paid: true)
    create(:expense, user: user, date: Date.new(2026, 5, 20), amount: 35, category: 'car_wash', paid: false)
    create(:expense, user: user, date: Date.new(2026, 4, 16), amount: 100, category: 'fuel', vendor: 'Posto Orense', paid: true)
    create(:expense, user: create(:user), date: Date.new(2026, 5, 22), amount: 500, category: 'fuel', vendor: 'Posto Orense', paid: true)
  end

  it 'sums, counts and averages an expense slice of the period, naming its single category' do
    summary = summary_for(History::Slice.new(categories: %w[fuel], vendors: { 'fuel' => ['Posto Orense'] }))

    expect(summary).to eq(kind: :expenses, total: 125, count: 2, average: 62.5, pending: 0, category: 'fuel')
  end

  it 'sums the unpaid expenses of the slice as pending and names no category for two of them' do
    summary = summary_for(History::Slice.new(categories: %w[fuel car_wash]))

    expect(summary).to eq(kind: :expenses, total: 160, count: 3, average: 53.33, pending: 35, category: nil)
  end

  it 'sums, counts and averages an earning slice' do
    summary = summary_for(History::Slice.new(platforms: %w[uber]))

    expect(summary).to eq(kind: :earnings, total: 50.5, count: 2, average: 25.25, pending: 0, category: nil)
  end

  it 'keeps the three totals for a slice that mixes earnings and expenses, netting only the paid expenses' do
    summary = summary_for(History::Slice.new(platforms: %w[uber], categories: %w[fuel car_wash]))

    expect(summary).to eq(kind: :mixed, earnings: 50.5, expenses: 160, net: -74.5)
  end
end

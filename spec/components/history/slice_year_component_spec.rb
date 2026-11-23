require 'rails_helper'

RSpec.describe History::SliceYearComponent, type: :component do
  let(:months) do
    (0..11).map do |offset|
      date = Date.new(2025, 6, 1) >> offset
      { year: date.year, month: date.month, total: offset < 7 ? 189.9 : 214.3, count: 1 }
    end
  end
  let(:year) do
    { kind: :expenses, series: 'insurance', months: months, total: 2400.8, average: 200.07, count: 12, rows: [],
      shift: { year: 2026, month: 1, from: 189.9, to: 214.3, change: 12.8 }, highlighted: [7, 8, 9, 10, 11] }
  end
  let(:slice) { History::Slice.new(categories: %w[insurance], range: '12m') }
  let(:page) { Capybara.string(view_context.render(described_class.new(year: year, slice: slice, query: nil))) }

  before { travel_to Time.zone.local(2026, 5, 22, 10, 0) }

  it 'titles the card by the series and shows the window total in red' do
    expect(page).to have_text('Seguro · por mês')
    expect(page.find('[data-twelve-months="total"]').text).to eq('R$ 2.400,80')
    expect(page.find('[data-twelve-months="total"]')[:class]).to include('text-red-700')
  end

  it 'keeps the currency glued to the average so the line never breaks after R$' do
    expect(page.find('[data-twelve-months="summary"]').native.text).to eq("em 12 meses · média R$\u00A0200,07/mês")
  end

  it 'drops the totals spacing on desktop so the bars align with the badge' do
    expect(page.find('[data-twelve-months="totals"]')[:class].split).to include('mb-2', 'lg:mb-0')
  end

  it 'flags the raise in amber with the levels on desktop' do
    badge = page.find('[data-twelve-months="adjustment"]')

    expect(badge[:class]).to include('text-amber-800 bg-amber-100 border border-amber-200')
    expect(badge.text).to eq('Reajuste +12,8% em jan · R$ 189,90 → R$ 214,30')
    expect(badge.find('.hidden.lg\:inline').text).to eq('· R$ 189,90 → R$ 214,30')
  end

  it 'signs a fall with a minus' do
    falling = Capybara.string(view_context.render(described_class.new(year: year.merge(shift: { year: 2026, month: 3, from: 200, to: 180,
                                                                                                change: -10.0 }), slice: slice, query: nil)))

    expect(falling.find('[data-twelve-months="adjustment"]')).to have_text('Reajuste −10,0% em mar')
  end

  it 'draws the twelve bars highlighted from the raise to the end' do
    bars = page.all('[data-trend-bar]')

    expect(bars.map { |bar| bar[:class].include?('bg-red-600') }).to eq([false] * 7 + [true] * 5)
  end

  it 'shows no badge without a raise and paints an earning series green' do
    earning = Capybara.string(view_context.render(described_class.new(year: year.merge(kind: :earnings, series: 'uber', shift: nil,
                                                                                       highlighted: [11]), slice: slice, query: nil)))

    expect(earning).to have_no_css('[data-twelve-months="adjustment"]')
    expect(earning).to have_text('Uber · por mês')
    expect(earning.find('[data-twelve-months="total"]')[:class]).to include('text-emerald-700')
    expect(earning.all('[data-trend-bar]').last[:class]).to include('bg-emerald-600')
  end

  it 'puts the mode toggle in the header on phones only' do
    expect(page.find('[data-twelve-months="card"] .lg\:hidden')).to have_css('[data-mode-toggle="twelve_months"]')
  end
end

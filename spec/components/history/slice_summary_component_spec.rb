require 'rails_helper'

RSpec.describe History::SliceSummaryComponent, type: :component do
  let(:expenses) { { kind: :expenses, total: 125, count: 2, average: 62.5, pending: 0, category: 'fuel' } }

  def tiles_of(summary)
    Capybara.string(view_context.render(described_class.new(summary: summary))).all('[data-slice-summary="tiles"] > div')
  end

  def labels(tiles) = tiles.map { |tile| tile.all('p').first.text }

  def values(tiles) = tiles.map { |tile| tile.all('p').last.text }

  it 'shows the spent total in red, the refuelings count and the average for a fuel slice' do
    tiles = tiles_of(expenses)

    expect(labels(tiles)).to eq(%w[spent refuelings average].map { |key| I18n.t("history.index.slice_summary.#{key}") })
    expect(values(tiles)).to eq(['R$ 125,00', '2', 'R$ 62,50'])
    expect(tiles.first[:class]).to include('bg-red-50 border-red-200 text-red-900')
  end

  it 'swaps the average for the pending total and counts records for another slice' do
    tiles = tiles_of(expenses.merge(pending: 35, category: nil))

    expect(labels(tiles)).to eq(%w[spent records pending].map { |key| I18n.t("history.index.slice_summary.#{key}") })
    expect(values(tiles).last).to eq('R$ 35,00')
  end

  it 'shows the received total in green for an earning slice' do
    tile = tiles_of(kind: :earnings, total: 50.5, count: 2, average: 25.25, pending: 0, category: nil).first

    expect(tile).to have_text(I18n.t('history.index.slice_summary.received'))
    expect(tile[:class]).to include('bg-emerald-50 border-emerald-200 text-emerald-900')
  end

  it 'keeps the compact phone tiles and the larger desktop values of the prototype' do
    html = view_context.render(described_class.new(summary: expenses))

    expect(html).to include('grid grid-cols-3 gap-2 lg:gap-4')
    expect(html).to include('text-[10px] font-medium uppercase tracking-wide opacity-70')
    expect(html).to include('text-sm font-bold tabular-nums mt-0.5 lg:text-2xl lg:mt-1')
  end
end

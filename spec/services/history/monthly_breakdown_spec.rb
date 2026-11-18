require 'rails_helper'

RSpec.describe History::MonthlyBreakdown do
  let(:window) { (0..11).map { |offset| date = Date.new(2025, 6, 1) >> offset; [date.year, date.month] } }

  def breakdown(totals) = described_class.new(window: window, totals: totals).call

  context 'with an insurance bill raised in january' do
    let(:totals) { window.each_with_index.to_h { |key, index| [key, { total: index < 7 ? 189.9 : 214.3, count: 1 }] } }
    let(:result) { breakdown(totals) }

    it 'sums the window and averages it over the twelve months' do
      expect(result[:total]).to eq(2400.8)
      expect(result[:average]).to eq(200.07)
    end

    it 'reports the raise and highlights the bars from it to the end' do
      expect(result[:shift]).to eq(year: 2026, month: 1, from: 189.9, to: 214.3, change: 12.8)
      expect(result[:highlighted]).to eq([7, 8, 9, 10, 11])
    end

    it 'lists the months newest first, comparing each with the previous logged month' do
      expect(result[:rows].size).to eq(12)
      expect(result[:rows].first).to eq(year: 2026, month: 5, total: 214.3, count: 1, previous_month: 4, change: 0.0, equal: true, shift: false)
      expect(result[:rows][4]).to eq(year: 2026, month: 1, total: 214.3, count: 1, previous_month: 12, change: 12.8, equal: false, shift: true)
      expect(result[:rows].last).to eq(year: 2025, month: 6, total: 189.9, count: 1, previous_month: nil, change: nil, equal: false, shift: false)
    end
  end

  context 'with gaps and a late start' do
    let(:totals) { { [2026, 2] => { total: 120.0, count: 2 }, [2026, 4] => { total: 90.0, count: 1 }, [2026, 5] => { total: 95.0, count: 3 } } }
    let(:result) { breakdown(totals) }

    it 'zero fills the bars and averages from the first logged month to the end of the window' do
      expect(result[:months].map { |month| month[:total] }).to eq([0, 0, 0, 0, 0, 0, 0, 0, 120.0, 0, 90.0, 95.0])
      expect(result[:months][9]).to eq(year: 2026, month: 3, total: 0, count: 0)
      expect(result[:total]).to eq(305.0)
      expect(result[:average]).to eq(76.25)
    end

    it 'skips the empty months in the list and compares across the gap' do
      expect(result[:rows].map { |row| [row[:month], row[:previous_month], row[:change]] }).to eq([[5, 4, 5.6], [4, 2, -25.0], [2, nil, nil]])
    end

    it 'highlights only the last bar without a raise' do
      expect(result[:shift]).to be_nil
      expect(result[:highlighted]).to eq([11])
    end
  end

  it 'returns a zeroed breakdown for an empty window' do
    expect(breakdown({})).to include(total: 0, average: 0, rows: [], shift: nil, highlighted: [11])
  end
end

require 'rails_helper'

RSpec.describe History::LevelShift do
  def months(*totals) = totals.each_with_index.map { |total, index| { year: 2025, month: index + 1, total: total } }

  def shift(*totals) = described_class.new(months(*totals)).call

  it 'finds the jump that started the current stable level with both levels' do
    expect(shift(189.9, 189.9, 189.9, 214.3, 214.3)).to eq(year: 2025, month: 4, from: 189.9, to: 214.3, change: 12.8)
  end

  it 'detects a fall the same way' do
    expect(shift(200, 200, 180, 180)).to eq(year: 2025, month: 3, from: 200, to: 180, change: -10.0)
  end

  it 'ignores the months with nothing logged' do
    expect(shift(189.9, 0, 189.9, 0, 214.3, 214.3)).to include(month: 5, from: 189.9, to: 214.3)
  end

  it 'tolerates one percent of wobble inside each level' do
    expect(shift(100, 100.5, 100.2, 110, 110.9)).to eq(year: 2025, month: 4, from: 100.2, to: 110, change: 9.8)
  end

  it 'only reports the most recent jump' do
    expect(shift(150, 150, 180, 180, 200, 200)).to include(month: 5, from: 180, to: 200, change: 11.1)
  end

  it 'stays silent for a variable expense' do
    expect(shift(352, 388, 341, 402, 389, 420)).to be_nil
  end

  it 'stays silent without two stable months before the jump' do
    expect(shift(189.9, 214.3, 214.3)).to be_nil
  end

  it 'stays silent below a two percent jump' do
    expect(shift(100, 100, 101.5, 101.5)).to be_nil
  end

  it 'stays silent when the whole window is one level' do
    expect(shift(189.9, 189.9, 189.9)).to be_nil
  end
end

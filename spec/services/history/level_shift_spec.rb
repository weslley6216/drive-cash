require 'rails_helper'

RSpec.describe History::LevelShift do
  it 'finds the jump that started the current stable level with both levels' do
    months = [189.9, 189.9, 189.9, 214.3, 214.3].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to eq(year: 2025, month: 4, from: 189.9, to: 214.3, change: 12.8)
  end

  it 'detects a fall the same way' do
    months = [200, 200, 180, 180].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to eq(year: 2025, month: 3, from: 200, to: 180, change: -10.0)
  end

  it 'ignores the months with nothing logged' do
    months = [189.9, 0, 189.9, 0, 214.3, 214.3].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to include(month: 5, from: 189.9, to: 214.3)
  end

  it 'tolerates one percent of wobble inside each level' do
    months = [100, 100.5, 100.2, 110, 110.9].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to eq(year: 2025, month: 4, from: 100.2, to: 110, change: 9.8)
  end

  it 'only reports the most recent jump' do
    months = [150, 150, 180, 180, 200, 200].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to include(month: 5, from: 180, to: 200, change: 11.1)
  end

  it 'stays silent for a variable expense' do
    months = [352, 388, 341, 402, 389, 420].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to be_nil
  end

  it 'stays silent without two stable months before the jump' do
    months = [189.9, 214.3, 214.3].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to be_nil
  end

  it 'stays silent below a two percent jump' do
    months = [100, 100, 101.5, 101.5].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to be_nil
  end

  it 'stays silent when the whole window is one level' do
    months = [189.9, 189.9, 189.9].each.with_index(1).map { |total, month| { year: 2025, month: month, total: total } }

    expect(described_class.new(months).call).to be_nil
  end
end

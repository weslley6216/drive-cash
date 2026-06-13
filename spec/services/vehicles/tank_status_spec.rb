require 'rails_helper'

RSpec.describe Vehicles::TankStatus do
  it 'returns ok above 25 percent' do
    status = described_class.for(125, 260)

    expect(status.key).to eq(:ok)
    expect(status.bar_class).to eq('bg-blue-500')
    expect(status.color).to eq('#2563eb')
  end

  it 'returns low at or below 25 percent' do
    status = described_class.for(60, 260)

    expect(status.key).to eq(:low)
    expect(status.num_class).to eq('text-amber-700')
  end

  it 'returns empty when balance is zero' do
    status = described_class.for(0, 260)

    expect(status.key).to eq(:empty)
    expect(status.chip_class).to eq('text-red-700 bg-red-100 border-red-200')
  end

  it 'returns negative when balance is below zero' do
    status = described_class.for(-15, 260)

    expect(status.key).to eq(:negative)
    expect(status.bar_class).to eq('bg-red-500')
  end

  it 'treats nil full as zero ratio' do
    status = described_class.for(50, nil)

    expect(status.key).to eq(:low)
  end
end

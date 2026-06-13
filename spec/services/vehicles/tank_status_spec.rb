require 'rails_helper'

RSpec.describe Vehicles::TankStatus do
  it 'returns ok above 25 percent' do
    expect(described_class.for(125, 260)).to eq(:ok)
  end

  it 'returns low at or below 25 percent' do
    expect(described_class.for(60, 260)).to eq(:low)
  end

  it 'returns empty when balance is zero' do
    expect(described_class.for(0, 260)).to eq(:empty)
  end

  it 'returns negative when balance is below zero' do
    expect(described_class.for(-15, 260)).to eq(:negative)
  end

  it 'treats nil full as zero ratio' do
    expect(described_class.for(50, nil)).to eq(:low)
  end
end

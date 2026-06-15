require 'rails_helper'

RSpec.describe Vehicles::TankStatus do
  it 'returns ok at or above 75 percent' do
    expect(described_class.for(195, 260)).to eq(:ok)
  end

  it 'returns mid between 50 and 75 percent' do
    expect(described_class.for(130, 260)).to eq(:mid)
  end

  it 'returns low between 25 and 50 percent' do
    expect(described_class.for(70, 260)).to eq(:low)
  end

  it 'returns critical below 25 percent' do
    expect(described_class.for(30, 260)).to eq(:critical)
  end

  it 'returns empty when balance is zero' do
    expect(described_class.for(0, 260)).to eq(:empty)
  end

  it 'returns negative when balance is below zero' do
    expect(described_class.for(-15, 260)).to eq(:negative)
  end

  it 'treats nil full as critical' do
    expect(described_class.for(50, nil)).to eq(:critical)
  end
end

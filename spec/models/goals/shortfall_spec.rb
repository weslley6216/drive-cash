require 'rails_helper'

RSpec.describe Goals::Shortfall do
  it 'truncates the reached percent and keeps what was missing' do
    shortfall = described_class.new(target: BigDecimal('1100'), achieved: BigDecimal('987.40'))

    expect(shortfall).to have_attributes(percent: 89, amount: BigDecimal('112.60'))
  end

  it 'never reads a full percent for a goal one cent short' do
    shortfall = described_class.new(target: BigDecimal('1000'), achieved: BigDecimal('999.99'))

    expect(shortfall.percent).to eq(99)
  end

  it 'floors a negative profit at zero percent and counts the whole gap' do
    shortfall = described_class.new(target: BigDecimal('1000'), achieved: BigDecimal('-150'))

    expect(shortfall).to have_attributes(percent: 0, amount: BigDecimal('1150'))
  end

  it 'calls a result from eighty percent near' do
    expect(described_class.new(target: BigDecimal('1000'), achieved: BigDecimal('800'))).to be_near
  end

  it 'calls a result under eighty percent closed' do
    expect(described_class.new(target: BigDecimal('1000'), achieved: BigDecimal('799.99'))).not_to be_near
  end
end

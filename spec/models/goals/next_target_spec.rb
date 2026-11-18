require 'rails_helper'

RSpec.describe Goals::NextTarget do
  it 'adds five percent to the result and rounds up to the next hundred' do
    expect(described_class.new(result: BigDecimal('6120')).amount).to eq(6_500)
  end

  it 'keeps an exact hundred after the five percent' do
    expect(described_class.new(result: BigDecimal('6000')).amount).to eq(6_300)
  end

  it 'rounds a result with cents up to the next hundred' do
    expect(described_class.new(result: BigDecimal('987.40')).amount).to eq(1_100)
  end
end

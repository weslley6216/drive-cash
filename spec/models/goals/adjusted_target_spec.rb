require 'rails_helper'

RSpec.describe Goals::AdjustedTarget do
  it 'rounds the recent average down to the ten below' do
    expect(described_class.new(average: BigDecimal('1057.90'), target: BigDecimal('1100')).amount).to eq(1_050)
  end

  it 'keeps an average already on the ten' do
    expect(described_class.new(average: BigDecimal('1040'), target: BigDecimal('1100')).amount).to eq(1_040)
  end

  it 'offers no adjustment when the average reaches the target' do
    expect(described_class.new(average: BigDecimal('1500'), target: BigDecimal('1100')).amount).to be_nil
  end

  it 'offers no adjustment when the average rounds down to the target' do
    expect(described_class.new(average: BigDecimal('1105'), target: BigDecimal('1100')).amount).to be_nil
  end

  it 'offers no adjustment when the average rounds down to zero' do
    expect(described_class.new(average: BigDecimal('5'), target: BigDecimal('1100')).amount).to be_nil
  end

  it 'offers no adjustment without an average' do
    expect(described_class.new(average: nil, target: BigDecimal('1100')).amount).to be_nil
  end
end

require 'rails_helper'

RSpec.describe Goals::AdjustedTarget do
  def adjusted(average)
    described_class.new(average: average, target: BigDecimal('1100')).amount
  end

  it 'rounds the recent average down to the ten below' do
    expect(adjusted(BigDecimal('1057.90'))).to eq(1_050)
  end

  it 'keeps an average already on the ten' do
    expect(adjusted(BigDecimal('1040'))).to eq(1_040)
  end

  it 'offers no adjustment when the average reaches the target' do
    expect(adjusted(BigDecimal('1500'))).to be_nil
  end

  it 'offers no adjustment when the average rounds down to the target' do
    expect(adjusted(BigDecimal('1105'))).to be_nil
  end

  it 'offers no adjustment when the average rounds down to zero' do
    expect(adjusted(BigDecimal('5'))).to be_nil
  end

  it 'offers no adjustment without an average' do
    expect(adjusted(nil)).to be_nil
  end
end

require 'rails_helper'

RSpec.describe Goals::PeriodLabel do
  it 'names a monthly period by its month' do
    label = described_class.new(kind: 'monthly', period: Date.new(2026, 6, 1)..Date.new(2026, 6, 30))

    expect(label.short).to eq('junho')
    expect(label.full).to eq('Junho · 2026')
  end

  it 'names a weekly period by its first and last day' do
    label = described_class.new(kind: 'weekly', period: Date.new(2026, 6, 29)..Date.new(2026, 7, 5))

    expect(label.short).to eq('29/jun a 05/jul')
    expect(label.full).to eq('29/jun a 05/jul · 2026')
  end

  it 'names an annual period by its year' do
    label = described_class.new(kind: 'annual', period: Date.new(2026, 1, 1)..Date.new(2026, 12, 31))

    expect(label.short).to eq('2026')
    expect(label.full).to eq('2026')
  end
end

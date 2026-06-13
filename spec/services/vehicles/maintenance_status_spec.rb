require 'rails_helper'

RSpec.describe Vehicles::MaintenanceStatus do
  it 'returns ok below 80 percent' do
    status = described_class.for(79.9)

    expect(status.key).to eq(:ok)
    expect(status.color).to eq('#10b981')
  end

  it 'returns soon between 80 and 100 percent' do
    status = described_class.for(80)

    expect(status.key).to eq(:soon)
    expect(status.color).to eq('#f59e0b')
    expect(status.badge_class).to eq('text-amber-700 bg-amber-100 border-amber-200')
  end

  it 'returns overdue at 100 percent or more' do
    status = described_class.for(120)

    expect(status.key).to eq(:overdue)
    expect(status.color).to eq('#dc2626')
    expect(status.tint_class).to eq('border-red-200 bg-red-50/60')
  end
end

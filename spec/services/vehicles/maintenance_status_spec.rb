require 'rails_helper'

RSpec.describe Vehicles::MaintenanceStatus do
  it 'returns ok below 80 percent' do
    expect(described_class.for(79.9)).to eq(:ok)
  end

  it 'returns soon between 80 and 100 percent' do
    expect(described_class.for(80)).to eq(:soon)
  end

  it 'returns overdue at 100 percent or more' do
    expect(described_class.for(120)).to eq(:overdue)
  end
end

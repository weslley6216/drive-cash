require 'rails_helper'

RSpec.describe MaintenancePalette do
  let(:palette) { Class.new { include MaintenancePalette }.new }

  it 'maps each maintenance category to its lucide icon' do
    expect(palette.maintenance_icon('timing_belt')).to eq(PhlexIcons::Lucide::Settings)
    expect(palette.maintenance_icon('oil_change')).to eq(PhlexIcons::Lucide::Wrench)
  end

  it 'falls back to Wrench for unknown categories' do
    expect(palette.maintenance_icon('gearbox')).to eq(PhlexIcons::Lucide::Wrench)
  end
end

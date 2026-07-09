require 'rails_helper'

RSpec.describe CategoryPalette do
  let(:palette) { Class.new { include CategoryPalette }.new }

  it 'returns the prototype color and icon for a known category' do
    expect(palette.category_color('toll')).to eq('#3b82f6')
    expect(palette.category_icon('toll')).to eq(PhlexIcons::Lucide::Route)
  end

  it 'maps car_wash to its prototype color and icon' do
    expect(palette.category_color('car_wash')).to eq('#8b5cf6')
    expect(palette.category_icon('car_wash')).to eq(PhlexIcons::Lucide::Sparkles)
  end

  it 'includes the other bucket' do
    expect(palette.category_color('other')).to eq('#64748b')
    expect(palette.category_icon('other')).to eq(PhlexIcons::Lucide::Package)
  end

  it 'falls back to slate color and Package icon for unknown categories' do
    expect(palette.category_color('something_new')).to eq('#94a3b8')
    expect(palette.category_icon('something_new')).to eq(PhlexIcons::Lucide::Package)
  end
end

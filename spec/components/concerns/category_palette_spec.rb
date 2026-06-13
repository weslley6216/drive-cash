require 'rails_helper'

RSpec.describe CategoryPalette do
  let(:palette) { Class.new { include CategoryPalette }.new }

  it 'returns the mapped color and icon for a known category' do
    expect(palette.category_color('fuel')).to eq('#dc2626')
    expect(palette.category_icon('fuel')).to eq(PhlexIcons::Lucide::Fuel)
  end

  it 'falls back to slate color and Package icon for unknown categories' do
    expect(palette.category_color('something_new')).to eq('#94a3b8')
    expect(palette.category_icon('something_new')).to eq(PhlexIcons::Lucide::Package)
  end
end

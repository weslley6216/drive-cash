require 'rails_helper'

RSpec.describe PlatformPalette do
  let(:palette) { Class.new { include PlatformPalette }.new }

  it 'returns the mapped color for a known platform' do
    expect(palette.platform_color('uber')).to eq('#000000')
  end

  it 'falls back to slate color for unknown platforms' do
    expect(palette.platform_color('other')).to eq('#94a3b8')
  end
end

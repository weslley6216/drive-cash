require 'rails_helper'

RSpec.describe PlatformPalette do
  let(:palette) { Class.new { include PlatformPalette }.new }

  it 'returns the mapped color for a known platform' do
    expect(palette.platform_color('ifood')).to eq('#ef4444')
  end

  it 'returns the mapped foreground for a known platform' do
    expect(palette.platform_fg('nine_nine')).to eq('#000000')
  end

  it 'maps the other bucket to slate' do
    expect(palette.platform_color('other')).to eq('#cbd5e1')
    expect(palette.platform_fg('other')).to eq('#0f172a')
  end

  it 'falls back to slate color and dark foreground for unknown platforms' do
    expect(palette.platform_color('unknown_app')).to eq('#94a3b8')
    expect(palette.platform_fg('unknown_app')).to eq('#0f172a')
  end
end

require 'rails_helper'

RSpec.describe SplashScreenLinksComponent, type: :component do
  let(:html) { view_context.render(described_class.new) }
  let(:links) { Nokogiri::HTML.fragment(html).css('link[rel="apple-touch-startup-image"]') }

  it 'declares one launch image per iPhone screen' do
    expect(links.size).to eq(described_class::SCREENS.size)
  end

  it 'targets the iPhone 13 screen in portrait with its own image' do
    expect(html).to include(
      '<link rel="apple-touch-startup-image" ' \
      'media="(device-width: 390px) and (device-height: 844px) and (-webkit-device-pixel-ratio: 3) and (orientation: portrait)" ' \
      'href="/splash/splash-1170x2532.png">'
    )
  end

  it 'points every launch image to a file in public sized to the screen pixels' do
    described_class::SCREENS.each do |screen|
      path = Rails.public_path.join("splash/splash-#{screen[:width] * screen[:ratio]}x#{screen[:height] * screen[:ratio]}.png")
      header = File.binread(path, 24)

      expect(header[16, 8].unpack('NN')).to eq([screen[:width] * screen[:ratio], screen[:height] * screen[:ratio]])
    end
  end
end

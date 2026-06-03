require 'rails_helper'

RSpec.describe LogoGaugeComponent, type: :component do
  it 'renders an SVG with viewBox 0 0 100 100 by default' do
    html = view_context.render(described_class.new)

    expect(html).to include('viewBox="0 0 100 100"')
    expect(html).to include('width="32"')
    expect(html).to include('height="32"')
  end

  it 'renders the outer gauge arc with the fg color' do
    html = view_context.render(described_class.new(fg: '#fff'))

    expect(html).to include('M29.4 76.5 A32 32 0 1 1 70.6 76.5')
    expect(html).to include('stroke="#fff"')
  end

  it 'renders the accent arc with the accent color' do
    html = view_context.render(described_class.new(accent: '#10b981'))

    expect(html).to include('M66 24.3 A32 32 0 0 1 70.6 76.5')
    expect(html).to include('stroke="#10b981"')
  end

  it 'renders the needle line and hub circle with custom hub color' do
    html = view_context.render(described_class.new(hub: '#2563eb'))

    expect(html).to include('x1="50"')
    expect(html).to include('y1="52"')
    expect(html).to include('fill="#2563eb"')
  end

  it 'applies custom size to width and height' do
    html = view_context.render(described_class.new(size: 38))

    expect(html).to include('width="38"')
    expect(html).to include('height="38"')
  end
end

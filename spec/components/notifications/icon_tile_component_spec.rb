require 'rails_helper'

RSpec.describe Notifications::IconTileComponent, type: :component do
  it 'paints the palette of the key' do
    html = view_context.render(described_class.new(icon: PhlexIcons::Lucide::Bell, palette_key: :danger))

    expect(html).to include('bg-red-50')
    expect(html).to include('text-red-600')
  end

  it 'paints the attention palette in the amber of the prototype' do
    html = view_context.render(described_class.new(icon: PhlexIcons::Lucide::Bell, palette_key: :attention))

    expect(html).to include('bg-amber-50')
    expect(html).to include('text-amber-600')
  end

  it 'falls back to neutral for an unknown key' do
    html = view_context.render(described_class.new(icon: PhlexIcons::Lucide::Bell, palette_key: :unknown))

    expect(html).to include('bg-slate-100')
    expect(html).to include('text-slate-500')
  end

  it 'dims the tile when disabled' do
    html = view_context.render(described_class.new(icon: PhlexIcons::Lucide::Bell, palette_key: :neutral, dimmed: true))

    expect(html).to include('opacity-50')
  end

  it 'does not dim an enabled tile' do
    html = view_context.render(described_class.new(icon: PhlexIcons::Lucide::Bell, palette_key: :neutral, dimmed: false))

    expect(html).not_to include('opacity-50')
  end
end

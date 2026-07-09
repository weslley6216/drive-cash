require 'rails_helper'

RSpec.describe Records::PlatformPickerComponent, type: :component do
  let(:html) { view_context.render(described_class.new(selected: 'uber')) }

  it 'renders one option per Earning.platforms key' do
    expect(html.scan('type="radio"').size).to eq(Earning.platforms.size)
    Earning.platforms.each_key { |key| expect(html).to include("value=\"#{key}\"") }
  end

  it 'labels each platform from the earning platforms locale' do
    expect(html).to include(I18n.t('activerecord.attributes.earning.platforms.ifood'))
    expect(html).to include(I18n.t('activerecord.attributes.earning.platforms.other'))
  end

  it 'paints the avatar with the palette color and foreground' do
    expect(html).to include('background: #ef4444')
    expect(html).to include('color: #000000')
  end

  it 'uses CSS has-[:checked] for ring selection styling' do
    expect(html).to include('has-[:checked]:ring-2 has-[:checked]:ring-blue-500')
  end

  it 'uses a 4-column grid' do
    expect(html).to include('grid grid-cols-4')
  end

  it 'hides radios visually with sr-only' do
    expect(html).to match(/type="radio"[^>]*sr-only/)
  end

  it 'renders the section label' do
    expect(html).to include(I18n.t('records.new_view.platform_label'))
  end
end

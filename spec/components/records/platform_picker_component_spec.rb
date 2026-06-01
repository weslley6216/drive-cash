require 'rails_helper'

RSpec.describe Records::PlatformPickerComponent, type: :component do
  let(:html) { view_context.render(described_class.new(selected: 'uber')) }

  it 'renders 8 platform options' do
    expect(html.scan('type="radio"').size).to eq(8)
  end

  it 'renders all platforms from Earning.platforms keys' do
    Earning.platforms.each_key { |key| expect(html).to include("value=\"#{key}\"") }
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

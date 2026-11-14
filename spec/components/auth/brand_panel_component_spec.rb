require 'rails_helper'

RSpec.describe Auth::BrandPanelComponent, type: :component do
  let(:html) { view_context.render(described_class.new) }

  it 'renders the desktop-only gradient panel at 46% of the width' do
    expect(html).to include('hidden lg:flex w-[46%] flex-col justify-between p-12 relative overflow-hidden')
    expect(html).to include('linear-gradient(150deg,#1d4ed8 0%,#2563eb 55%,#3b82f6 100%)')
  end

  it 'renders the light brand mark, the headline, the profit card and the copyright' do
    expect(html).to include('text-blue-100')
    expect(html).to include(I18n.t('auth.brand_panel_component.headline_line1'))
    expect(html).to include(I18n.t('auth.brand_panel_component.headline_line2'))
    expect(html).to include(I18n.t('auth.brand_panel_component.subheadline'))
    expect(html).to include(I18n.t('auth.brand_panel_component.hero_profit_label'))
    expect(html).to include('R$ 16.555,27')
    expect(html).to include(I18n.t('auth.brand_panel_component.copyright'))
  end
end

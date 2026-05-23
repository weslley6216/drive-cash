require 'rails_helper'

RSpec.describe CajuQuickAccessComponent, type: :component do
  let(:html) { view_context.render(CajuQuickAccessComponent.new) }

  it 'links to chat_root_path' do
    expect(html).to include('href="/chat"')
  end

  it 'renders Caju title and examples' do
    expect(html).to include(I18n.t('caju_quick_access_component.title'))
    expect(html).to include('Fiz R$45 no Uber')
    expect(html).to include('Abasteci R$80')
  end

  it 'uses violet pastel palette' do
    expect(html).to include('bg-violet-50')
    expect(html).to include('border-violet-200')
  end

  it 'renders the Sparkles icon' do
    expect(html).to include('<svg')
  end
end

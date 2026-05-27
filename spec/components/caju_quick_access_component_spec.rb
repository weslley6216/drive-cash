require 'rails_helper'

RSpec.describe CajuQuickAccessComponent, type: :component do
  let(:html) { view_context.render(CajuQuickAccessComponent.new) }

  it 'links to chat_root_path' do
    expect(html).to include('href="/chat"')
  end

  it 'renders Caju title' do
    expect(html).to include(I18n.t('caju_quick_access_component.title'))
  end

  context 'mobile layout' do
    it 'renders mobile card hidden on desktop' do
      expect(html).to include('lg:hidden')
    end

    it 'uses white card with violet border for mobile' do
      expect(html).to include('bg-white')
      expect(html).to include('border-violet-100')
    end

    it 'renders examples text on mobile' do
      expect(html).to include('Fiz R$45 no Uber')
    end

    it 'renders Mic icon on mobile' do
      expect(html.scan('<svg').size).to be >= 2
    end
  end

  context 'desktop layout' do
    it 'renders desktop card hidden on mobile' do
      expect(html).to include('hidden lg:block')
    end

    it 'uses violet gradient for desktop' do
      expect(html).to include('from-violet-500')
      expect(html).to include('to-fuchsia-600')
    end

    it 'renders desktop CTA text' do
      expect(html).to include(I18n.t('caju_quick_access_component.cta_desktop'))
    end
  end
end

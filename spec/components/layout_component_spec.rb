require 'rails_helper'

RSpec.describe LayoutComponent, type: :component do
  context 'without bottom_nav' do
    let(:html) { view_context.render(LayoutComponent.new(title: 'X')) { 'content' } }

    it 'does not render the BottomNavComponent' do
      expect(html).not_to include('fixed bottom-0 left-0 right-0')
    end

    it 'does not apply pb-24 to the inner container' do
      expect(html).not_to include('pb-24')
    end

    it 'renders title and required PWA meta tags' do
      expect(html).to include('<title>X</title>')
      expect(html).to include('name="theme-color"')
      expect(html).to include('rel="manifest"')
    end
  end

  context 'with bottom_nav: :home' do
    let(:html) { view_context.render(LayoutComponent.new(title: 'X', bottom_nav: :home)) { 'content' } }

    it 'renders the BottomNavComponent' do
      expect(html).to include('fixed bottom-0 left-0 right-0')
      expect(html).to include('text-blue-600')
    end

    it 'adds pb-24 to the inner container' do
      expect(html).to include('pb-24')
    end
  end

  context 'with sidebar_nav: :home' do
    let(:html) do
      view_context.render(
        LayoutComponent.new(title: 'X', bottom_nav: :home, sidebar_nav: :home)
      ) { 'content' }
    end

    it 'renders the SidebarNavComponent' do
      expect(html).to include('sidebar-tab')
      expect(html).to include(I18n.t('sidebar_nav_component.brand'))
    end

    it 'applies flex layout on desktop' do
      expect(html).to include('lg:flex')
    end

    it 'wraps content in a desktop-aware container' do
      expect(html).to include('lg:ml-64')
    end

    it 'hides BottomNavComponent on desktop' do
      expect(html).to include('lg:hidden')
    end

    it 'still renders bottom nav for mobile' do
      expect(html).to include('fixed bottom-0')
    end
  end
end

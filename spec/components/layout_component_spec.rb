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
      expect(html).to include('max-w-7xl mx-auto pb-24')
    end
  end
end

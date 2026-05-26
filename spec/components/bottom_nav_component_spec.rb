require 'rails_helper'

RSpec.describe BottomNavComponent, type: :component do
  let(:html) { view_context.render(BottomNavComponent.new(active: active)) }

  context 'when active: :home' do
    let(:active) { :home }

    it 'renders 5 tabs with Lucide icons' do
      expect(html.scan('<a ').size).to eq(5)
      expect(html).to include(I18n.t('bottom_nav_component.tabs.home'))
      expect(html).to include(I18n.t('bottom_nav_component.tabs.analysis'))
      expect(html).to include(I18n.t('bottom_nav_component.tabs.journey'))
      expect(html).to include(I18n.t('bottom_nav_component.tabs.history'))
      expect(html).to include(I18n.t('bottom_nav_component.tabs.more'))
    end

    it 'positions nav fixed at the bottom with z-30' do
      expect(html).to include('fixed bottom-0 left-0 right-0')
      expect(html).to include('z-30')
    end

    it 'hides on desktop via lg:hidden' do
      expect(html).to include('lg:hidden')
    end

    it 'highlights the active tab with text-blue-600 and thicker stroke' do
      expect(html).to include('text-blue-600')
      expect(html).to include('stroke-[2.4]')
    end

    it 'dims inactive tabs with text-slate-400' do
      expect(html.scan('text-slate-400').size).to eq(4)
    end

    it 'links each tab to its corresponding route' do
      expect(html).to include('href="/"')
      expect(html).to include('href="/analysis"')
      expect(html).to include('href="/work_session"')
      expect(html).to include('href="/history"')
      expect(html).to include('href="/settings"')
    end
  end

  context 'when active: :analysis' do
    let(:active) { :analysis }

    it 'highlights only the analysis tab' do
      expect(html.scan('text-blue-600').size).to eq(1)
      expect(html).to include('href="/analysis"')
    end
  end
end

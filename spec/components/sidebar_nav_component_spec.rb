require 'rails_helper'

RSpec.describe SidebarNavComponent, type: :component do
  let(:html) { view_context.render(described_class.new(active: active)) }

  context 'when active: :home' do
    let(:active) { :home }

    it 'renders 6 navigation tabs' do
      expect(html.scan('sidebar-tab').size).to eq(6)
    end

    it 'renders all tab labels from i18n' do
      %w[home analysis goals journey history vehicle].each do |tab|
        expect(html).to include(I18n.t("sidebar_nav_component.tabs.#{tab}"))
      end
    end

    it 'highlights the active tab with blue styling' do
      expect(html).to include('bg-blue-50')
      expect(html).to include('text-blue-700')
    end

    it 'dims inactive tabs with slate styling' do
      expect(html.scan('text-slate-600').size).to be >= 5
    end

    it 'is hidden on mobile and visible on desktop' do
      expect(html).to include('hidden')
      expect(html).to include('lg:flex')
    end

    it 'renders BrandMarkComponent in the brand section' do
      expect(html).to include('w-9 h-9 rounded-lg')
      expect(html).to include('viewBox="0 0 100 100"')
      expect(html).not_to include('>DC<')
    end

    it 'renders the brand title and subtitle from i18n' do
      expect(html).to include(I18n.t('sidebar_nav_component.brand'))
      expect(html).to include(I18n.t('sidebar_nav_component.brand_subtitle'))
    end

    it 'renders the settings link at the bottom' do
      expect(html).to include(I18n.t('sidebar_nav_component.settings'))
      expect(html).to include('href="/settings"')
    end

    it 'links each tab to its route' do
      expect(html).to include('href="/"')
      expect(html).to include('href="/analysis"')
      expect(html).to include('href="/goals"')
      expect(html).to include('href="/work_session"')
      expect(html).to include('href="/history"')
      expect(html).to include('href="/vehicle"')
    end
  end

  context 'when active: :analysis' do
    let(:active) { :analysis }

    it 'highlights only the analysis tab' do
      expect(html.scan('bg-blue-50').size).to eq(1)
    end
  end
end

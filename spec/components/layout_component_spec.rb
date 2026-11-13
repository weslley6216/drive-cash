require 'rails_helper'

RSpec.describe LayoutComponent, type: :component do
  context 'without bottom_nav' do
    let(:html) { view_context.render(LayoutComponent.new(title: 'X')) { 'content' } }

    it 'does not render the BottomNavComponent' do
      expect(html).not_to include('id="bottom-nav"')
    end

    it 'renders title and required PWA meta tags' do
      expect(html).to include('<title>X</title>')
      expect(html).to include('name="theme-color"')
      expect(html).to include('rel="manifest"')
    end

    it 'keeps the iOS status bar opaque so content does not run under the clock and carrier' do
      expect(html).to include('name="apple-mobile-web-app-status-bar-style" content="default"')
    end

    it 'covers the whole screen so the safe-area insets reach the CSS' do
      expect(html).to include('name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover"')
    end

    it 'locks the app body to the viewport as a column so only the screen content scrolls' do
      expect(html).to include('<body class="h-[100dvh] flex flex-col overflow-hidden bg-gradient-to-br from-slate-50 to-slate-100">')
    end

    it 'gives the container the height left above the bottom nav' do
      expect(html).to include('<div class="flex-1 min-h-0"><div class="h-full max-w-7xl mx-auto flex flex-col min-h-0">')
    end

    it 'lets the status bar follow the device theme instead of forcing an accent color' do
      expect(html).to include('name="theme-color" media="(prefers-color-scheme: light)" content="#f8fafc"')
      expect(html).to include('name="theme-color" media="(prefers-color-scheme: dark)" content="#0f172a"')
    end

    it 'includes the turbo-refresh-method=morph meta tag so page refreshes use morphdom' do
      expect(html).to include('name="turbo-refresh-method"')
      expect(html).to include('content="morph"')
    end
  end

  context 'with bottom_nav: :home' do
    let(:html) { view_context.render(LayoutComponent.new(title: 'X', bottom_nav: :home)) { 'content' } }

    it 'renders the BottomNavComponent' do
      expect(html).to include('id="bottom-nav"')
      expect(html).to include('text-blue-600')
    end
  end

  it 'renders the loading overlay on an app page' do
    html = view_context.render(LayoutComponent.new(title: 'X')) { 'content' }

    expect(html).to include('id="loading-overlay"')
  end

  it 'keeps the Turbo cache by default' do
    html = view_context.render(LayoutComponent.new(title: 'X')) { 'content' }

    expect(html).not_to include('turbo-cache-control')
  end

  it 'opts out of the Turbo cache when asked' do
    html = view_context.render(LayoutComponent.new(title: 'X', turbo_cache: false)) { 'content' }

    expect(html).to include('name="turbo-cache-control" content="no-cache"')
  end

  it 'leaves the loading overlay out of the auth shell when auth: true' do
    html = view_context.render(LayoutComponent.new(title: 'X', auth: true)) { 'content' }

    expect(html).not_to include('id="loading-overlay"')
  end

  it 'pads the auth body by the top inset' do
    html = view_context.render(LayoutComponent.new(title: 'X', auth: true)) { 'content' }

    expect(html).to include('class="min-h-screen pt-[env(safe-area-inset-top)]"')
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

    it 'wraps content in a desktop-aware container beside the sidebar' do
      expect(html).to include('<div class="flex-1 min-h-0 lg:ml-60"><div class="h-full max-w-7xl mx-auto flex flex-col min-h-0 lg:px-8">')
    end

    it 'hides BottomNavComponent on desktop' do
      expect(html).to include('lg:hidden')
    end

    it 'still renders bottom nav for mobile' do
      expect(html).to include('id="bottom-nav"')
    end
  end
end

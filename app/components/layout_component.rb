class LayoutComponent < ApplicationComponent
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavascriptImportmapTags

  def initialize(title: 'DriveCash', bottom_nav: nil, sidebar_nav: nil, app_shell: false, auth: false)
    @title = title
    @bottom_nav = bottom_nav
    @sidebar_nav = sidebar_nav
    @app_shell = app_shell
    @auth = auth
  end

  def view_template(&block)
    doctype
    html(lang: 'pt-BR') do
      head_section
      body_section(&block)
    end
  end

  private

  def head_section
    head do
      title { @title }
      meta(name: 'viewport', content: 'width=device-width,initial-scale=1,viewport-fit=cover')
      meta(name: 'mobile-web-app-capable', content: 'yes')
      meta(name: 'apple-mobile-web-app-capable', content: 'yes')
      meta(name: 'apple-mobile-web-app-status-bar-style', content: 'black-translucent')
      meta(name: 'theme-color', content: '#3b82f6')
      meta(name: 'turbo-refresh-method', content: 'morph')
      meta(name: 'turbo-refresh-scroll', content: 'preserve')

      # PWA manifest
      link(rel: 'manifest', href: '/manifest.json')

      # Icons
      link(rel: 'icon', type: 'image/png', href: '/icon-192.png')
      link(rel: 'apple-touch-icon', href: '/icon-192.png')

      meta(name: 'turbo-cache-control', content: 'no-cache') if @auth
      csrf_meta_tags
      csp_meta_tag
      stylesheet_link_tag('tailwind', "data-turbo-track": 'reload')
      javascript_importmap_tags

      # Register service worker
      script do
        plain <<~JS.html_safe
          if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/service-worker.js')
              .then(reg => console.log('SW registered', reg))
              .catch(err => console.log('SW error', err));
          }
        JS
      end
    end
  end

  def body_section(&block)
    body(class: body_classes) do
      render SidebarNavComponent.new(active: @sidebar_nav) if @sidebar_nav && !@auth
      div(class: content_wrapper_classes) do
        div(class: container_classes, &block)
      end
      render BottomNavComponent.new(active: @bottom_nav) if @bottom_nav && !@auth
    end
  end

  def body_classes
    return 'min-h-screen' if @auth

    if @app_shell
      'h-[100dvh] overflow-hidden bg-gradient-to-br from-slate-50 to-slate-100'
    else
      base = 'min-h-screen bg-gradient-to-br from-slate-50 to-slate-100'
      @sidebar_nav ? "#{base} p-4 sm:p-6 lg:p-0" : "#{base} p-4 sm:p-6"
    end
  end

  def content_wrapper_classes
    return nil if @auth

    classes = []
    classes << 'lg:ml-64' if @sidebar_nav
    classes << 'h-full' if @app_shell
    classes.presence&.join(' ')
  end

  def container_classes
    return nil if @auth

    if @app_shell
      base = 'h-full max-w-7xl mx-auto flex flex-col min-h-0'
      @sidebar_nav ? "#{base} lg:px-8" : base
    else
      base = 'max-w-7xl mx-auto'
      base = "#{base} pb-24 lg:pb-6" if @bottom_nav
      base = "#{base} lg:p-8" if @sidebar_nav
      base
    end
  end
end

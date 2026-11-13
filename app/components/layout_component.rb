class LayoutComponent < ApplicationComponent
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavascriptImportmapTags

  def initialize(title: 'DriveCash', bottom_nav: nil, sidebar_nav: nil, auth: false, turbo_cache: true)
    @title = title
    @bottom_nav = bottom_nav
    @sidebar_nav = sidebar_nav
    @auth = auth
    @turbo_cache = turbo_cache
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
      meta(name: 'viewport', content: 'width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover')
      meta(name: 'mobile-web-app-capable', content: 'yes')
      meta(name: 'apple-mobile-web-app-capable', content: 'yes')
      meta(name: 'apple-mobile-web-app-status-bar-style', content: 'default')
      meta(name: 'theme-color', media: '(prefers-color-scheme: light)', content: '#f8fafc')
      meta(name: 'theme-color', media: '(prefers-color-scheme: dark)', content: '#0f172a')
      meta(name: 'turbo-refresh-method', content: 'morph')
      meta(name: 'turbo-refresh-scroll', content: 'preserve')

      link(rel: 'manifest', href: '/manifest.json')

      link(rel: 'icon', type: 'image/png', href: '/icon-192.png')
      link(rel: 'apple-touch-icon', href: '/icon.png')

      meta(name: 'turbo-cache-control', content: 'no-cache') if @auth || !@turbo_cache
      csrf_meta_tags
      csp_meta_tag
      stylesheet_link_tag('tailwind', "data-turbo-track": 'reload')
      javascript_importmap_tags
    end
  end

  def body_section(&block)
    body(class: body_classes) do
      render LoadingOverlayComponent.new unless @auth
      render SidebarNavComponent.new(active: @sidebar_nav) if @sidebar_nav && !@auth
      div(class: content_wrapper_classes) do
        div(class: container_classes, &block)
      end
      render BottomNavComponent.new(active: @bottom_nav) if @bottom_nav && !@auth
    end
  end

  def body_classes
    return 'min-h-screen pt-[env(safe-area-inset-top)]' if @auth

    'h-[100dvh] overflow-hidden bg-gradient-to-br from-slate-50 to-slate-100'
  end

  def content_wrapper_classes
    return nil if @auth

    class_names('h-full', ('lg:ml-60' if @sidebar_nav))
  end

  def container_classes
    return nil if @auth

    class_names('h-full max-w-7xl mx-auto flex flex-col min-h-0', ('lg:px-8' if @sidebar_nav))
  end
end

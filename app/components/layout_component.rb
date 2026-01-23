class LayoutComponent < ApplicationComponent
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavascriptImportmapTags

  def initialize(title: 'DriveCash')
    @title = title
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

      # PWA manifest
      link(rel: 'manifest', href: '/manifest.json')

      # Icons
      link(rel: 'icon', type: 'image/png', href: '/icon-192.png')
      link(rel: 'apple-touch-icon', href: '/icon-192.png')

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
    body(class: 'min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 p-4 sm:p-6') do
      div(class: 'max-w-7xl mx-auto', &block)
    end
  end
end

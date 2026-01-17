# frozen_string_literal: true

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
      meta(name: 'viewport', content: 'width=device-width,initial-scale=1')
      csrf_meta_tags
      csp_meta_tag
      stylesheet_link_tag('tailwind', "data-turbo-track": 'reload')
      javascript_importmap_tags
    end
  end

  def body_section(&block)
    body(class: 'min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 p-6') do
      div(class: 'max-w-7xl mx-auto', &block)
    end
  end
end

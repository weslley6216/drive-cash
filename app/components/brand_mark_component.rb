class BrandMarkComponent < ApplicationComponent
  SIZES = {
    sm: { box: 'w-9 h-9 rounded-lg',    title: nil,        gauge: 22, wordmark_default: false },
    md: { box: 'w-11 h-11 rounded-xl',  title: 'text-xl',  gauge: 30, wordmark_default: true },
    lg: { box: 'w-14 h-14 rounded-2xl', title: 'text-2xl', gauge: 38, wordmark_default: true }
  }.freeze

  def initialize(size: :md, light: false, wordmark: nil)
    @size     = size
    @light    = light
    @config   = SIZES.fetch(size)
    @wordmark = wordmark.nil? ? @config[:wordmark_default] : wordmark
  end

  def view_template
    div(class: 'flex items-center gap-3') do
      div(class: "#{@config[:box]} flex items-center justify-center #{@light ? 'bg-white' : 'bg-blue-600'}") do
        render LogoGaugeComponent.new(
          size:   @config[:gauge],
          fg:     @light ? '#2563eb' : '#fff',
          accent: '#10b981',
          hub:    @light ? '#fff' : '#2563eb'
        )
      end
      render_wordmark if @wordmark && @config[:title]
    end
  end

  private

  def render_wordmark
    div do
      p(class: "#{@config[:title]} font-bold leading-none tracking-tight #{@light ? 'text-white' : 'text-slate-900'}") do
        t('brand_mark_component.title')
      end
      p(class: "text-[11px] mt-1 #{@light ? 'text-blue-100' : 'text-slate-500'}") do
        t('brand_mark_component.subtitle')
      end
    end
  end
end

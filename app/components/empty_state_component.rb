class EmptyStateComponent < ApplicationComponent
  def initialize(icon:, title:, description:, cta_label:, cta_path:, cta_icon:,
                 icon_color: 'text-slate-400', ring: 'bg-slate-100 border-slate-200',
                 cta_data: {}, secondary_label: nil, secondary_path: nil)
    @icon = icon
    @title = title
    @description = description
    @cta_label = cta_label
    @cta_path = cta_path
    @cta_icon = cta_icon
    @icon_color = icon_color
    @ring = ring
    @cta_data = cta_data
    @secondary_label = secondary_label
    @secondary_path = secondary_path
  end

  def view_template
    div(class: 'flex flex-col items-center justify-center text-center px-6 py-10') do
      icon_ring
      h2(class: 'text-lg font-bold text-slate-800') { @title }
      p(class: 'text-sm text-slate-500 mt-2 max-w-[250px] leading-relaxed') { @description }
      cta_link
      secondary_link
    end
  end

  private

  def icon_ring
    div(class: "w-20 h-20 rounded-full border flex items-center justify-center mb-5 #{@ring}") do
      render @icon.new(class: "w-8 h-8 #{@icon_color}")
    end
  end

  def cta_link
    link_to(@cta_path, data: @cta_data, class: cta_classes) do
      render @cta_icon.new(class: 'w-4 h-4')
      plain @cta_label
    end
  end

  def cta_classes
    'mt-5 inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white ' \
    'rounded-xl px-5 py-3 text-sm font-bold shadow-sm shadow-blue-600/20'
  end

  def secondary_link
    return if @secondary_label.nil?

    link_to(@secondary_path, class: 'mt-3 text-xs font-semibold text-blue-600') { @secondary_label }
  end
end

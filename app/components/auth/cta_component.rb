class Auth::CtaComponent < ApplicationComponent
  def initialize(label:, icon: PhlexIcons::Lucide::ArrowRight, href: nil)
    @label = label
    @icon = icon
    @href = href
  end

  def view_template
    if @href
      link_to(@href, class: classes) { content }
    else
      button(type: 'submit', class: classes) { content }
    end
  end

  private

  def content
    plain @label
    render @icon.new(class: 'w-4 h-4 stroke-[2.4]') if @icon
  end

  def classes
    'w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-3.5 lg:py-3 text-sm font-semibold ' \
    'shadow-lg shadow-blue-600/25 flex items-center justify-center gap-2 cursor-pointer'
  end
end

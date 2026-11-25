class BackLinkComponent < ApplicationComponent
  def initialize(fallback:, label:)
    @fallback = fallback
    @label = label
  end

  def view_template
    link_to(helpers.return_path(fallback: @fallback), class: 'p-1 -ml-1 mt-0.5 text-slate-500', aria: { label: @label }) do
      render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
    end
  end
end

module Exports
  class FormatPillComponent < ApplicationComponent
    def initialize(icon:, title:, sub:, value:, selected:)
      @icon = icon
      @title = title
      @sub = sub
      @value = value
      @selected = selected
    end

    def view_template
      label(class: container_classes, data: { controller: 'export-pill' }) do
        input(type: 'radio', name: 'export[format]', value: @value, checked: @selected, class: 'sr-only', data: { action: 'change->export-pill#select' })
        div(class: 'flex items-center justify-between mb-1.5') do
          div(class: badge_classes) { render @icon.new(class: 'w-[18px] h-[18px]') }
          if @selected
            render PhlexIcons::Lucide::Check.new(class: 'w-[18px] h-[18px] text-blue-600')
          end
        end
        p(class: 'text-sm font-semibold text-slate-800') { @title }
        p(class: 'text-xs text-slate-500') { @sub }
      end
    end

    private

    def container_classes
      base = 'flex-1 rounded-2xl border p-3.5 text-left transition cursor-pointer'
      @selected ? "#{base} border-blue-500 bg-blue-50 ring-2 ring-blue-500/30" : "#{base} border-slate-200 bg-white"
    end

    def badge_classes
      base = 'w-9 h-9 rounded-lg flex items-center justify-center'
      @selected ? "#{base} bg-blue-600 text-white" : "#{base} bg-slate-100 text-slate-500"
    end
  end
end

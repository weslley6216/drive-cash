module Exports
  class IncludeRowComponent < ApplicationComponent
    def initialize(icon:, label:, sub:, key:, checked:, last: false)
      @icon = icon
      @label = label
      @sub = sub
      @key = key
      @checked = checked
      @last = last
    end

    def view_template
      label(class: container_classes) do
        input(type: 'hidden', name: "export[includes][#{@key}]", value: '0')
        input(type: 'checkbox', name: "export[includes][#{@key}]", value: '1', checked: @checked, class: 'sr-only peer')
        div(class: 'w-9 h-9 rounded-lg bg-slate-100 text-slate-500 flex items-center justify-center flex-shrink-0') do
          render @icon.new(class: 'w-[17px] h-[17px]')
        end
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-sm font-medium text-slate-800') { @label }
          p(class: 'text-xs text-slate-500') { @sub }
        end
        div(class: 'relative w-11 h-6 rounded-full bg-slate-300 peer-checked:bg-blue-600 transition') do
          span(class: 'absolute top-0.5 left-0.5 w-5 h-5 rounded-full bg-white shadow peer-checked:translate-x-5 transition')
        end
      end
    end

    private

    def container_classes
      base = 'flex items-center gap-3 px-4 py-3 cursor-pointer'
      @last ? base : "#{base} border-b border-slate-100"
    end
  end
end

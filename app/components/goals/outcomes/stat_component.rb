module Goals
  module Outcomes
    class StatComponent < ApplicationComponent
      def initialize(label:, value:, sub: nil, tone: 'text-slate-800')
        @label = label
        @value = value
        @sub = sub
        @tone = tone
      end

      def view_template
        div(class: 'min-w-0') do
          p(class: 'text-[10px] font-medium text-slate-500 uppercase tracking-wide') { @label }
          p(class: "text-sm font-bold mt-0.5 tabular-nums #{@tone}") { @value }
          p(class: 'text-[11px] text-slate-400 leading-tight mt-0.5') { @sub } if @sub
        end
      end
    end
  end
end

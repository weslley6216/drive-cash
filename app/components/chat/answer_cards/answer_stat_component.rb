module Chat
  module AnswerCards
    class AnswerStatComponent < ApplicationComponent
      ROW = 'flex items-center gap-3 py-2.5'.freeze
      TONES = {
        emerald: { chip: 'bg-emerald-100 text-emerald-600', value: 'text-emerald-700' },
        red:     { chip: 'bg-red-100 text-red-600', value: 'text-red-700' },
        violet:  { chip: 'bg-violet-100 text-violet-600', value: 'text-slate-800' },
        slate:   { chip: 'bg-slate-100 text-slate-500', value: 'text-slate-800' }
      }.freeze

      def initialize(label:, value:, icon:, tone: :slate, detail: nil)
        @label = label
        @value = value
        @icon = icon
        @tone = tone
        @detail = detail
      end

      def view_template
        div(class: ROW) do
          div(class: class_names('w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0', palette[:chip])) do
            render @icon.new(class: 'w-4 h-4')
          end
          div(class: 'flex-1 min-w-0') do
            p(class: 'text-sm text-slate-600 leading-tight') { @label }
            p(class: 'text-xs text-slate-400 leading-tight mt-0.5 truncate') { @detail } if @detail
          end
          p(class: class_names('text-sm font-semibold tabular-nums whitespace-nowrap', palette[:value])) { @value }
        end
      end

      private

      def palette = TONES.fetch(@tone, TONES[:slate])
    end
  end
end

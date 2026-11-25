module Chat
  module AnswerCards
    class AnswerStatComponent < ApplicationComponent
      ROW = 'flex items-center justify-between gap-3 py-2 sm:block sm:flex-1 sm:px-3 sm:py-0 sm:first:pl-0 sm:last:pr-0'.freeze
      TONES = { emerald: 'text-emerald-700', red: 'text-red-700', slate: 'text-slate-800' }.freeze

      def initialize(label:, value:, tone: :slate)
        @label = label
        @value = value
        @tone = tone
      end

      def view_template
        div(class: ROW) do
          p(class: 'text-[10px] font-medium text-slate-400 uppercase tracking-wide') { @label }
          p(class: class_names('text-sm font-bold tabular-nums whitespace-nowrap', tone_class)) { @value }
        end
      end

      private

      def tone_class = TONES.fetch(@tone, TONES[:slate])
    end
  end
end

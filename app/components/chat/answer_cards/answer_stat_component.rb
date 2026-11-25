module Chat
  module AnswerCards
    class AnswerStatComponent < ApplicationComponent
      TONES = { emerald: 'text-emerald-700', red: 'text-red-700', slate: 'text-slate-800' }.freeze

      def initialize(label:, value:, tone: :slate)
        @label = label
        @value = value
        @tone = tone
      end

      def view_template
        div(class: 'flex-1') do
          p(class: 'text-[10px] font-medium text-slate-400 uppercase tracking-wide') { @label }
          p(class: class_names('text-sm font-bold tabular-nums', tone_class)) { @value }
        end
      end

      private

      def tone_class = TONES.fetch(@tone, TONES[:slate])
    end
  end
end

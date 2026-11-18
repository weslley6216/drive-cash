module Goals
  module Outcomes
    class JourneyComponent < ApplicationComponent
      include CardStyles

      def initialize(outcome:)
        @outcome = outcome
      end

      def view_template
        div(class: "#{CARD} p-4") do
          h3(class: 'text-sm font-semibold text-slate-800 mb-3') { t('goals.outcomes.show.journey.title') }
          render PaceStatsComponent.new(outcome: @outcome)
          streak_line if @outcome.streak >= 2
        end
      end

      private

      def streak_line
        p(class: 'flex items-center gap-2 mt-4 pt-3 border-t border-slate-100 text-xs text-slate-600') do
          span(class: 'w-6 h-6 rounded-full bg-orange-50 text-orange-500 flex items-center justify-center flex-shrink-0') do
            render PhlexIcons::Lucide::Flame.new(class: 'w-[13px] h-[13px]')
          end
          plain t("goals.outcomes.show.journey.streak.#{@outcome.goal.kind}", count: @outcome.streak)
        end
      end
    end
  end
end

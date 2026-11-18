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
          stats_grid
          streak_line if @outcome.streak >= 2
        end
      end

      private

      def stats_grid
        div(class: 'grid grid-cols-3 gap-2') do
          render StatComponent.new(label: t('goals.outcomes.show.journey.worked_days'), value: @outcome.worked_days)
          render StatComponent.new(label: per_day_label, value: format_currency(@outcome.per_day))
          render StatComponent.new(label: t('goals.outcomes.show.journey.best_day'),
                                   value: format_currency(@outcome.best_day.value),
                                   sub:   I18n.l(@outcome.best_day.date, format: :weekday_day_abbr))
        end
      end

      def streak_line
        p(class: 'flex items-center gap-2 mt-4 pt-3 border-t border-slate-100 text-xs text-slate-600') do
          span(class: 'w-6 h-6 rounded-full bg-orange-50 text-orange-500 flex items-center justify-center flex-shrink-0') do
            render PhlexIcons::Lucide::Flame.new(class: 'w-[13px] h-[13px]')
          end
          plain t("goals.outcomes.show.journey.streak.#{@outcome.goal.kind}", count: @outcome.streak)
        end
      end

      def per_day_label
        t("goals.outcomes.show.journey.per_day.#{@outcome.goal.metric}")
      end
    end
  end
end

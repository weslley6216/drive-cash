module Goals
  module Outcomes
    class PaceStatsComponent < ApplicationComponent
      def initialize(outcome:)
        @outcome = outcome
      end

      def view_template
        div(class: 'grid grid-cols-3 gap-2') do
          render StatComponent.new(label: t('goals.outcomes.show.journey.worked_days'), value: @outcome.worked_days)
          render StatComponent.new(label: per_day_label, value: format_currency(@outcome.per_day))
          render StatComponent.new(label: t('goals.outcomes.show.journey.best_day'),
                                   value: format_currency(@outcome.best_day.value),
                                   sub:   I18n.l(@outcome.best_day.date, format: :weekday_day_abbr))
        end
      end

      private

      def per_day_label
        t("goals.outcomes.show.journey.per_day.#{@outcome.goal.metric}")
      end
    end
  end
end

module Goals
  module Outcomes
    class NextGoalLinkComponent < ApplicationComponent
      def initialize(goal:, next_period:)
        @goal = goal
        @next_period = next_period
      end

      def view_template
        link_to(goals_path(**path_params),
                class: 'mt-2 text-sm font-semibold text-blue-700 flex items-center gap-1.5') do
          plain t('goals.outcomes.show.next_step.view_next', period: period_label.short)
          render PhlexIcons::Lucide::ArrowRight.new(class: 'w-[14px] h-[14px]')
        end
      end

      private

      def path_params
        return {} unless @goal.kind_monthly?

        { month: @next_period.first.month, year: @next_period.first.year }
      end

      def period_label
        Goals::PeriodLabel.new(kind: @goal.kind, period: @next_period)
      end
    end
  end
end

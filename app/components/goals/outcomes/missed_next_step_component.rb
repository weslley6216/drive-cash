module Goals
  module Outcomes
    class MissedNextStepComponent < ApplicationComponent
      def initialize(outcome:)
        @outcome = outcome
      end

      def render? = @outcome.next_period.present?

      def view_template
        div(class: 'rounded-2xl bg-blue-50 border border-blue-200 p-4') do
          kicker
          if @outcome.next_goal
            render NextGoalLinkComponent.new(goal: @outcome.goal, next_period: @outcome.next_period)
          else
            within_reach
            pace
            buttons
          end
        end
      end

      private

      def kicker
        p(class: 'text-xs font-semibold text-blue-700 uppercase tracking-wider') do
          t('goals.outcomes.show.next_step.kicker')
        end
      end

      def within_reach
        p(class: 'text-base font-bold text-slate-900 mt-1') do
          t('goals.outcomes.missed.next_step.within_reach', amount: format_currency(@outcome.target))
        end
      end

      def pace
        p(class: 'text-xs text-slate-600 mt-1 leading-relaxed') do
          plain pace_text
          plain ' '
          plain t("goals.outcomes.missed.next_step.shorter.#{@outcome.goal.kind}")
        end
      end

      def pace_text
        t('goals.outcomes.missed.next_step.pace', count:   @outcome.work_days,
                                                  per_day: format_currency(@outcome.per_work_day),
                                                  period:  current_period_label)
      end

      def current_period_label
        return t("goals.outcomes.missed.next_step.current_period.#{@outcome.goal.kind}") if @outcome.next_period.cover?(Date.current)

        Goals::PeriodLabel.new(kind: @outcome.goal.kind, period: @outcome.next_period).short
      end

      def buttons
        div(class: class_names('grid gap-2 mt-3', @outcome.adjusted_target ? 'grid-cols-2' : 'grid-cols-1')) do
          render NextGoalButtonComponent.new(label: t('goals.outcomes.missed.next_step.keep'), goal: @outcome.goal,
                                             next_period: @outcome.next_period, target_amount: @outcome.target,
                                             primary: true)
          adjust_button if @outcome.adjusted_target
        end
      end

      def adjust_button
        render NextGoalButtonComponent.new(
          label:         t('goals.outcomes.missed.next_step.adjust', amount: format_currency_short(@outcome.adjusted_target)),
          goal:          @outcome.goal,
          next_period:   @outcome.next_period,
          target_amount: @outcome.adjusted_target,
          primary:       false
        )
      end
    end
  end
end

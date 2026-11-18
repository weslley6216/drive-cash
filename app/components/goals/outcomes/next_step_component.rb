module Goals
  module Outcomes
    class NextStepComponent < ApplicationComponent
      include OutcomeLabels

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
            question
            explanation
            actions
          end
        end
      end

      private

      def kicker
        p(class: 'text-xs font-semibold text-blue-700 uppercase tracking-wider') do
          t('goals.outcomes.show.next_step.kicker')
        end
      end

      def question
        p(class: 'text-base font-bold text-slate-900 mt-1') do
          t('goals.outcomes.show.next_step.question', amount: format_currency(@outcome.suggestion),
                                                      period: next_period_label.short)
        end
      end

      def explanation
        p(class: 'text-xs text-slate-600 mt-1 leading-relaxed') do
          t('goals.outcomes.show.next_step.explanation', period:  period_label.short,
                                                         per_day: format_currency(@outcome.suggestion.fdiv(@outcome.worked_days)))
        end
      end

      def actions
        div(class: 'grid grid-cols-2 gap-2 mt-3') do
          render NextGoalButtonComponent.new(label: t('goals.outcomes.show.next_step.raise'), goal: @outcome.goal,
                                             next_period: @outcome.next_period, target_amount: @outcome.suggestion,
                                             primary: true)
          render NextGoalButtonComponent.new(
            label:         t('goals.outcomes.show.next_step.keep', amount: format_currency_short(@outcome.target)),
            goal:          @outcome.goal,
            next_period:   @outcome.next_period,
            target_amount: @outcome.target,
            primary:       false
          )
        end
      end

      def next_period_label
        Goals::PeriodLabel.new(kind: @outcome.goal.kind, period: @outcome.next_period)
      end
    end
  end
end

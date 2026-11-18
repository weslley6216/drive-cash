module Goals
  module Outcomes
    class NextStepComponent < ApplicationComponent
      include Phlex::Rails::Helpers::ButtonTo
      include OutcomeLabels

      def initialize(outcome:)
        @outcome = outcome
      end

      def render? = @outcome.next_period.present?

      def view_template
        div(class: 'rounded-2xl bg-blue-50 border border-blue-200 p-4') do
          kicker
          if @outcome.next_goal
            next_goal_link
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
          button_to(t('goals.outcomes.show.next_step.raise'), goals_path, params: goal_params(@outcome.suggestion),
                    class: 'bg-blue-600 text-white rounded-xl py-3 text-sm font-semibold w-full', form_class: 'contents')
          button_to(t('goals.outcomes.show.next_step.keep', amount: format_currency_short(@outcome.target)), goals_path,
                    params:     goal_params(@outcome.target),
                    class:      'bg-white border border-slate-200 text-slate-700 rounded-xl py-3 text-sm font-semibold w-full',
                    form_class: 'contents')
        end
      end

      def next_goal_link
        link_to(goals_path(**next_goal_path_params),
                class: 'mt-2 text-sm font-semibold text-blue-700 flex items-center gap-1.5') do
          plain t('goals.outcomes.show.next_step.view_next', period: next_period_label.short)
          render PhlexIcons::Lucide::ArrowRight.new(class: 'w-[14px] h-[14px]')
        end
      end

      def next_goal_path_params
        return {} unless @outcome.goal.kind_monthly?

        { month: @outcome.next_period.first.month, year: @outcome.next_period.first.year }
      end

      def goal_params(target_amount)
        {
          goal: {
            kind:          @outcome.goal.kind,
            metric:        @outcome.goal.metric,
            target_amount: target_amount,
            period_start:  @outcome.next_period.first,
            period_end:    @outcome.next_period.last
          }
        }
      end

      def next_period_label
        Goals::PeriodLabel.new(kind: @outcome.goal.kind, period: @outcome.next_period)
      end
    end
  end
end

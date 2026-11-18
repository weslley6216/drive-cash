module Goals
  module Outcomes
    class NextGoalButtonComponent < ApplicationComponent
      include Phlex::Rails::Helpers::ButtonTo

      PRIMARY_CLASS = 'bg-blue-600 text-white rounded-xl py-3 text-sm font-semibold w-full'.freeze
      SECONDARY_CLASS = 'bg-white border border-slate-200 text-slate-700 rounded-xl py-3 text-sm font-semibold w-full'.freeze

      def initialize(label:, goal:, next_period:, target_amount:, primary:)
        @label = label
        @goal = goal
        @next_period = next_period
        @target_amount = target_amount
        @primary = primary
      end

      def view_template
        button_to(@label, goals_path, params: goal_params, class: @primary ? PRIMARY_CLASS : SECONDARY_CLASS,
                  form_class: 'contents')
      end

      private

      def goal_params
        {
          goal: {
            kind:          @goal.kind,
            metric:        @goal.metric,
            target_amount: @target_amount,
            period_start:  @next_period.first,
            period_end:    @next_period.last
          }
        }
      end
    end
  end
end

module Notifications
  module Generators
    class GoalReached
      def initialize(context)
        @context = context
      end

      def call
        progress = Goals::ProgressService.new(user: @context.user, date: @context.date).monthly
        return [] unless progress && progress[:reached]

        goal = progress[:goal]
        [{
          kind:  'goal_reached',
          data:  {
            'goal_id' => goal.id,
            'month'   => goal.period_start.to_s,
            'current' => progress[:current].to_f
          },
          dedup: { 'goal_id' => goal.id }
        }]
      end
    end
  end
end

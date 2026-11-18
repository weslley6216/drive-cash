module Notifications
  module Generators
    class GoalReached
      def initialize(context)
        @context = context
      end

      def call
        goals = @context.user.goals.active_at(@context.date).to_a
        totals = Goals::DailyTotals.for_goals(user: @context.user, goals: goals)

        goals.filter_map { |goal| payload_for(goal, totals) }
      end

      private

      def payload_for(goal, totals)
        current = totals.metric_for(goal)
        return nil if current < goal.target_amount

        {
          kind:  'goal_reached',
          data:  {
            'goal_id'      => goal.id,
            'period_start' => goal.period_start.to_s,
            'kind'         => goal.kind,
            'metric'       => goal.metric,
            'target'       => goal.target_amount.to_f,
            'current'      => current.to_f
          },
          dedup: { 'goal_id' => goal.id }
        }
      end
    end
  end
end

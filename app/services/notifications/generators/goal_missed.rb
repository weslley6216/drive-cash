module Notifications
  module Generators
    class GoalMissed
      def initialize(context)
        @context = context
      end

      def call
        goals = @context.user.goals.where(period_end: @context.date - 1).to_a
        totals = Goals::DailyTotals.for_goals(user: @context.user, goals: goals)

        goals.filter_map { |goal| payload_for(goal, totals) }
      end

      private

      def payload_for(goal, totals)
        return nil unless totals.active_in?(goal.period_start..goal.period_end)

        current = totals.metric_for(goal)
        return nil if current >= goal.target_amount

        {
          kind:  'goal_missed',
          data:  {
            'goal_id'      => goal.id,
            'period_start' => goal.period_start.to_s,
            'kind'         => goal.kind,
            'metric'       => goal.metric,
            'target'       => goal.target_amount.to_f,
            'current'      => current.to_f
          },
          dedup: { 'goal_id' => goal.id, 'period_start' => goal.period_start.to_s }
        }
      end
    end
  end
end

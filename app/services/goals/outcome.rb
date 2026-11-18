module Goals
  class Outcome
    STATES = [Goals::Outcomes::Hit, Goals::Outcomes::Missed].freeze

    def initialize(goal:, date: Date.current)
      @goal = goal
      @date = date
    end

    def call
      totals = Goals::DailyTotals.for(user: @goal.user, range: Goals::RecentPeriods.span(@goal))
      achieved = totals.metric_for(@goal)
      state = STATES.find { |candidate| candidate.applies?(goal: @goal, achieved: achieved, date: @date) }
      return nil unless state

      state.new(goal: @goal, totals: totals, date: @date).call
    end
  end
end

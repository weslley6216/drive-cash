module Goals
  class TrackRecord
    LOOKBACK = 4
    Result = Data.define(:hits, :total)

    def initialize(goal:)
      @goal = goal
    end

    def call
      previous = @goal.user.goals.for_kind(@goal.kind)
        .where('period_end < ?', @goal.period_start)
        .order(period_start: :desc)
        .limit(LOOKBACK).to_a
      return nil if previous.size < 2

      totals = Goals::DailyTotals.for_goals(user: @goal.user, goals: previous)
      hits = previous.count { |candidate| totals.metric_for(candidate) >= candidate.target_amount }
      return nil if hits * 2 < previous.size

      Result.new(hits: hits, total: previous.size)
    end
  end
end

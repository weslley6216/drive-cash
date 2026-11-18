module Goals
  class Streak
    def initialize(goal:)
      @goal = goal
    end

    def count
      chain = adjacent_chain(previous_candidates)
      return 1 if chain.empty?

      totals = Goals::DailyTotals.for_goals(user: @goal.user, goals: chain)
      hit_count = chain.take_while { |previous| totals.metric_for(previous) >= previous.target_amount }.size
      1 + hit_count
    end

    private

    def previous_candidates
      @goal.user.goals.for_kind(@goal.kind)
        .where('period_end < ?', @goal.period_start)
        .order(period_start: :desc)
    end

    def adjacent_chain(candidates)
      chain = []
      expected_end = @goal.period_start - 1
      candidates.each do |candidate|
        break unless candidate.period_end == expected_end

        chain << candidate
        expected_end = candidate.period_start - 1
      end
      chain
    end
  end
end

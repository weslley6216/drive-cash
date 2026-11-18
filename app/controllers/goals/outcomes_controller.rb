module Goals
  class OutcomesController < ApplicationController
    include GoalOutcomeVisit

    def show
      outcome = Goals::Outcome.new(goal: @goal).call
      return redirect_to goals_path unless outcome

      render Goals::Outcomes::ShowView.new(outcome: outcome, confetti: celebrate_real_visit(outcome))
    end
  end
end

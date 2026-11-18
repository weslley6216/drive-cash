module GoalOutcomeVisit
  extend ActiveSupport::Concern

  included do
    before_action :require_owned_goal_outcome
  end

  private

  def require_owned_goal_outcome
    @goal = current_user.goals.find_by(id: params[:goal_id])
    head :not_found if @goal.nil? || @goal.period_start.to_s != params[:period_start]
  end

  def celebrate_real_visit
    request.headers['X-Sec-Purpose'] != 'prefetch' && @goal.celebrate!
  end
end

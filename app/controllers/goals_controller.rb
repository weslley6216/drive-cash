class GoalsController < ApplicationController
  before_action :find_goal, only: %i[edit update destroy]
  before_action :reject_ended_goal, only: %i[edit update]
  before_action :load_filters, only: :index

  def index
    service = Goals::ProgressService.new(user: current_user, date: filter_reference_date)
    render Goals::IndexView.new(progress: service.call, filters: @filters, past_monthly: service.past_goals('monthly'))
  end

  def new
    @goal = current_user.goals.new(Goal.new_form_defaults)
    render Goals::NewView.new(goal: @goal)
  end

  def create
    @goal = current_user.goals.new(goal_params)
    if @goal.save
      flash[:notice] = t('goals.index.created')
      respond_with_modal_refresh(html_redirect: goals_path)
    else
      flash.now[:alert] = @goal.errors.full_messages.to_sentence
      render Goals::NewView.new(goal: @goal), status: :unprocessable_content
    end
  end

  def edit
    render Goals::EditView.new(goal: @goal)
  end

  def update
    if @goal.update(goal_params)
      flash[:notice] = t('goals.index.updated')
      respond_with_modal_refresh(html_redirect: goals_path)
    else
      flash.now[:alert] = @goal.errors.full_messages.to_sentence
      render Goals::EditView.new(goal: @goal), status: :unprocessable_content
    end
  end

  def destroy
    @goal.destroy
    flash[:notice] = t('goals.index.destroyed')
    respond_with_refresh(html_redirect: goals_path)
  end

  private

  def find_goal
    @goal = current_user.goals.find(params[:id])
  end

  def reject_ended_goal
    return unless @goal.ended?

    flash[:alert] = t('goals.index.ended_not_editable')
    respond_with_modal_refresh(html_redirect: goals_path)
  end

  def goal_params
    params.require(:goal).permit(:kind, :target_amount, :period_start, :period_end, :metric)
  end

  def load_filters
    set_dashboard_filters(month_default: Date.current.month)
  end
end

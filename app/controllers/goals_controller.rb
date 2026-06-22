class GoalsController < ApplicationController
  before_action :find_goal, only: %i[edit update destroy]

  def index
    filters = dashboard_filters
    first_day = Date.new(filters[:year], filters[:month], 1)
    reference_date = Date.current.between?(first_day, first_day.end_of_month) ? Date.current : first_day.end_of_month
    service = Goals::ProgressService.new(user: current_user, date: reference_date)
    progress = service.call
    past_monthly = service.past_goals('monthly')
    render Goals::IndexView.new(progress: progress, filters: filters, past_monthly: past_monthly)
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

  def goal_params
    params.require(:goal).permit(:kind, :target_amount, :period_start, :period_end, :metric)
  end

  def dashboard_filters
    { year: params[:year]&.to_i || Date.current.year, month: params[:month]&.to_i || Date.current.month }
  end
end

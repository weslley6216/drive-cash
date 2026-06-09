class DashboardController < ApplicationController
  before_action :set_filters, only: [:index, :earnings_detail, :expenses_detail]

  def index
    @totals = Dashboard::StatsService.new(year: @year, month: @month, user: current_user).call
    @recent_activity = Dashboard::RecentActivityService.new(year: @year, month: @month, user: current_user).call
    @categories = Dashboard::CategoryBreakdownService.new(year: @year, month: @month, user: current_user).call
    @today = Dashboard::TodayService.new(user: current_user).call
    @monthly_goal = if @month
                      Goals::ProgressService.new(user: current_user, date: Date.new(@year, @month, 1)).call[:monthly]
    end

    render Dashboard::IndexView.new(
      totals: @totals,
      filters: @filters,
      recent_activity: @recent_activity,
      categories: @categories,
      today: @today,
      monthly_goal: @monthly_goal
    )
  end

  def earnings_detail
    detail = Dashboard::EarningsDetailService.new(year: @year, month: @month, user: current_user).call

    render Dashboard::EarningsDetailView.new(**detail, filters: @filters)
  end

  def expenses_detail
    detail = Dashboard::ExpensesDetailService.new(year: @year, month: @month, user: current_user).call

    render Dashboard::ExpensesDetailView.new(**detail, filters: @filters)
  end

  private

  def set_filters
    @year = params[:year].presence&.to_i || Date.current.year
    @month = params[:month].presence&.to_i
    @available_years = available_years
    @filters = { year: @year, month: @month, available_years: @available_years }
  end

  def available_years = Dashboard::AvailableYears.fetch(user: current_user)
end

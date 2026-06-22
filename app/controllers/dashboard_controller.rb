class DashboardController < ApplicationController
  before_action :set_dashboard_filters, only: %i[index earnings_detail expenses_detail]

  def index
    @totals = Dashboard::StatsService.new(year: @year, month: @month, user: current_user).call
    @recent_activity = Dashboard::RecentActivityService.new(year: @year, month: @month, user: current_user).call
    @categories = Dashboard::CategoryBreakdownService.new(year: @year, month: @month, user: current_user).call
    @today = Dashboard::TodayService.new(user: current_user).call
    @monthly_goal = Goals::ProgressService.new(user: current_user, date: filter_reference_date).call[:monthly]

    render Dashboard::IndexView.new(
      totals:          @totals,
      first_name:      current_user.first_name,
      filters:         @filters,
      recent_activity: @recent_activity,
      categories:      @categories,
      today:           @today,
      monthly_goal:    @monthly_goal
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
end

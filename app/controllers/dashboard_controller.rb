class DashboardController < ApplicationController
  before_action :set_dashboard_filters, only: %i[index earnings_detail expenses_detail]

  def index
    home = Dashboard::HomeService.new(user: current_user, year: @year, month: @month, reference_date: filter_reference_date).call

    render Dashboard::IndexView.new(
      **home,
      first_name:   current_user.first_name,
      unread_count: current_user.visible_notifications.unread.count,
      filters:      @filters
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

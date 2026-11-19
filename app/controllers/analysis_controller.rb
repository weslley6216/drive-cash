class AnalysisController < ApplicationController
  before_action :set_calendar_filters

  def show
    @insights = Dashboard::InsightsService.new(year: @year, month: @month, user: current_user).call
    render Analysis::ShowView.new(insights: @insights, filters: @filters, unread_count: current_user.unread_notifications_count)
  end
end

class AnalysisController < ApplicationController
  def show
    @year = params[:year].presence&.to_i || Date.current.year
    @month = params[:month].presence&.to_i
    @available_years = Dashboard::AvailableYears.fetch(user: current_user)
    @filters = { year: @year, month: @month, available_years: @available_years }
    @insights = Dashboard::InsightsService.new(year: @year, month: @month, user: current_user).call

    render Analysis::ShowView.new(insights: @insights, filters: @filters)
  end
end

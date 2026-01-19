class DashboardController < ApplicationController
  before_action :set_filters, only: :index

  def index
    relation = Delivery.for_year(@year).for_month(@month).chronological
    @totals = DashboardService.new(relation).call

    render Dashboard::IndexView.new(totals: @totals, filters: @filters)
  end

  private

  def set_filters
    @year = params[:year].presence&.to_i || Date.current.year
    @month = params[:month].presence&.to_i
    @available_years = Delivery.available_years
    @filters = { year: @year, month: @month, available_years: @available_years }
  end
end

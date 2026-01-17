class DashboardController < ApplicationController
  def index
    year  = params[:year] || 2024
    month = params[:month]

    relation = Delivery.for_year(year)
                       .for_month(month)
                       .chronological

    @totals = DashboardService.new(relation).call

    render Dashboard::IndexView.new(totals: @totals)
  end
end

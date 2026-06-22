module DashboardContext
  extend ActiveSupport::Concern

  private

  def dashboard_context(record = nil)
    if record&.persisted?
      { year: record.date.year, month: record.date.month }
    else
      {
        year:  params.dig(:context, :year).presence&.to_i || Date.current.year,
        month: params.dig(:context, :month).presence&.to_i
      }
    end
  end

  def set_dashboard_filters(month_default: nil)
    @year = params[:year].presence&.to_i || Date.current.year
    @month = params[:month].presence&.to_i || month_default
    @available_years = Dashboard::AvailableYears.fetch(user: current_user)
    @filters = { year: @year, month: @month, available_years: @available_years }
  end

  def filter_reference_date
    return Date.current unless @month

    first_day = Date.new(@year, @month, 1)
    Date.current.between?(first_day, first_day.end_of_month) ? Date.current : first_day
  end
end

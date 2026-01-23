module DashboardContext
  extend ActiveSupport::Concern

  private

  def dashboard_context(record)
    if record&.persisted?
      { year: record.date.year, month: record.date.month }
    else
      { 
        year: params.dig(:context, :year).presence&.to_i || Date.current.year, 
        month: params.dig(:context, :month).presence 
      }
    end
  end
end

module HistoryFilters
  extend ActiveSupport::Concern

  private

  def set_history_filters
    set_calendar_filters
    @focus_day = focused_day
    return focus_period if @focus_day

    @query = params[:q].to_s.strip.presence
    @filter = History::FeedService.filter_names.include?(params[:filter]) ? params[:filter] : 'all'
  end

  def focus_period
    @year = @focus_day.year
    @month = @focus_day.month
    @query = nil
    @filter = 'all'
  end

  def focused_day
    day = Date.iso8601(params[:focus_day].to_s)
    day unless day.future?
  rescue ArgumentError
    nil
  end
end

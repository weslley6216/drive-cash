module HistoryFilters
  extend ActiveSupport::Concern

  private

  def set_history_filters
    set_calendar_filters
    @focus_day = focused_day
    @page = requested_page
    return focus_period if @focus_day

    @query = params[:q].to_s.strip.presence
    @filter = History::FeedService.filter_names.include?(params[:filter]) ? params[:filter] : 'all'
  end

  def focus_period
    @year = @focus_day.year
    @month = @focus_day.month
    @query = nil
    @filter = 'all'
    @page = 1
  end

  def focused_day
    day = Date.iso8601(params[:focus_day].to_s)
    day unless day.future?
  rescue ArgumentError
    nil
  end

  def requested_page
    page = params[:page].to_s
    return 1 unless page.match?(/\A\d{1,4}\z/) && page.to_i >= 1

    page.to_i
  end
end

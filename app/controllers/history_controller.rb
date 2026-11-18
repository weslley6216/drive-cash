class HistoryController < ApplicationController
  include HistoryFilters

  def index
    set_history_filters
    @feed = History::FeedService.new(year: @year, month: @month, query: @query, slice: @slice,
                                     focus_day: @focus_day, page: @page, user: current_user).call

    render History::IndexView.new(feed: @feed, year: @year, month: @month, query: @query,
                                  slice: @slice, periods: @periods)
  end
end

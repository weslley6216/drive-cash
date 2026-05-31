class HistoryController < ApplicationController
  ALLOWED_FILTERS = %w[all earnings expenses unpaid].freeze

  def index
    @year   = params[:year].presence&.to_i || Date.current.year
    @month  = params[:month].presence&.to_i
    @query  = params[:q].to_s.strip.presence
    @filter = ALLOWED_FILTERS.include?(params[:filter]) ? params[:filter] : 'all'

    @feed = History::FeedService.new(
      year: @year,
      month: @month,
      query: @query,
      filter: @filter
    ).call

    render History::IndexView.new(
      feed: @feed,
      year: @year,
      month: @month,
      query: @query,
      filter: @filter
    )
  end
end

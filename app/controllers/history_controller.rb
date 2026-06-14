class HistoryController < ApplicationController
  def index
    @year   = params[:year].presence&.to_i || Date.current.year
    @month  = params[:month].presence&.to_i
    @query  = params[:q].to_s.strip.presence
    @filter = History::FeedService.filter_names.include?(params[:filter]) ? params[:filter] : 'all'

    @feed = History::FeedService.new(
      year:   @year,
      month:  @month,
      query:  @query,
      filter: @filter,
      user:   current_user
    ).call

    @available_years = Dashboard::AvailableYears.fetch(user: current_user)

    render History::IndexView.new(
      feed:            @feed,
      year:            @year,
      month:           @month,
      query:           @query,
      filter:          @filter,
      available_years: @available_years
    )
  end
end

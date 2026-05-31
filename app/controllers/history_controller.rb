class HistoryController < ApplicationController
  def index
    @year   = params[:year].presence&.to_i || Date.current.year
    @month  = params[:month].presence&.to_i
    @query  = params[:q].to_s.strip.presence
    @filter = History::FeedService::FILTERS.include?(params[:filter]) ? params[:filter] : 'all'

    @feed = History::FeedService.new(
      year: @year,
      month: @month,
      query: @query,
      filter: @filter
    ).call

    earning_years = Earning.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::integer'))
    expense_years = Expense.distinct.pluck(Arel.sql('EXTRACT(YEAR FROM date)::integer'))
    @available_years = (earning_years + expense_years).uniq.sort.reverse
    @available_years = [Date.current.year] if @available_years.empty?

    render History::IndexView.new(
      feed: @feed,
      year: @year,
      month: @month,
      query: @query,
      filter: @filter,
      available_years: @available_years
    )
  end
end

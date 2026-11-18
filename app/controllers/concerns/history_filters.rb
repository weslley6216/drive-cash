module HistoryFilters
  extend ActiveSupport::Concern

  SLICE_PARAMS = [:unpaid, :range, { types: [], categories: [], platforms: [], vendors: Expense.categories.keys.index_with { [] } }].freeze

  private

  def set_history_filters
    set_calendar_filters
    @focus_day = focused_day
    @page = requested_page
    @slice = History::Slice.from_params(params.slice(:types, :unpaid, :categories, :platforms, :vendors, :range).permit(*SLICE_PARAMS).to_h)
    return focus_period if @focus_day

    @query = params[:q].to_s.strip.presence
  end

  def focus_period
    @year = @focus_day.year
    @month = @focus_day.month
    @query = nil
    @slice = History::Slice.new
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

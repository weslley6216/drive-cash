module Dashboard
  class DeleteRefreshView < ApplicationView
    include TurboSaveStreams

    def initialize(detail_view:, filter:, totals:)
      @detail_view = detail_view
      @filter = filter
      @totals = totals
    end

    def view_template
      raw turbo_stream.replace('modal') { render @detail_view }
      stats_grid_stream(totals: @totals, month: @filter[:month], year: @filter[:year])
      hero_stream(totals: @totals, year: @filter[:year], month: @filter[:month])
      today_card_stream
      recent_activity_stream(year: @filter[:year], month: @filter[:month])
      category_breakdown_stream(year: @filter[:year], month: @filter[:month])
      flash_stream('flash_modal', inline: true)
    end
  end
end

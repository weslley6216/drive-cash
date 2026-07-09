module Dashboard
  class DeleteRefreshView < ApplicationView
    include TurboSaveStreams

    def initialize(detail_view:, filter:, totals:)
      @detail_view = detail_view
      @filter = filter
      @totals = totals
    end

    def view_template
      modal_stream(@detail_view)
      flash_stream('flash_modal', inline: true)
      refresh_stream
    end
  end
end

module TurboUpdateResponse
  include TurboSaveStreams

  private

  def render_turbo_streams(record:, edit_view:, record_key:, detail_service:, detail_view:)
    if record.persisted? && @totals
      detail = detail_service.new(year: @context[:year], month: @context[:month]).call
      modal_stream(detail_view.new(**detail, filters: @context))
      stats_grid_stream(totals: @totals, month: @totals_context[:month], year: @totals_context[:year])
      flash_stream('flash_modal', inline: true)
    else
      modal_stream(edit_view.new(record_key => record, context: @context))
      flash_stream
    end
  end
end

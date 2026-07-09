module TurboUpdateResponse
  include TurboSaveStreams

  private

  def render_turbo_streams(record:, edit_view:, record_key:, detail:, detail_view:)
    if record.persisted? && @totals
      modal_stream(detail_view.new(**detail, filters: @context))
      flash_stream('flash_modal', inline: true)
      refresh_stream
    else
      modal_stream(edit_view.new(record_key => record, context: @context))
      flash_stream
    end
  end
end

module TurboCreateResponse
  include TurboSaveStreams

  private

  def render_turbo_streams(record:, new_view:, record_key:)
    if record.persisted? && @totals
      clear_modal_stream
      raw '<turbo-stream action="refresh"></turbo-stream>'.html_safe
    else
      modal_stream(new_view.new(record_key => record, context: @context))
    end

    flash_stream
  end
end

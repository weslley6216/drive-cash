module TurboCreateResponse
  include TurboSaveStreams

  private

  def render_turbo_streams(record:, new_view:, record_key:)
    if record.persisted? && @totals
      clear_modal_stream
      stats_grid_stream(totals: @totals, month: record.date.month, year: record.date.year)
      raw turbo_stream.replace('dashboard_filters') {
        render FilterComponent.new(
          selected_year: record.date.year,
          selected_month: record.date.month,
          available_years: Dashboard::AvailableYears.fetch
        )
      }
    else
      modal_stream(new_view.new(record_key => record, context: @context))
    end

    flash_stream
  end
end

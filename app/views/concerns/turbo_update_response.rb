module TurboUpdateResponse
  private

  def render_turbo_streams(record:, edit_view:, record_key:, detail_service:, detail_view:)
    if record.persisted? && @totals
      render_success(detail_service, detail_view)
    else
      render_failure(edit_view, record_key => record)
    end

    raw turbo_stream.update('flash') {
      render FlashComponent.new(flash: helpers.flash)
    }
  end

  def render_success(detail_service, detail_view)
    detail = detail_service.new(year: @context[:year], month: @context[:month]).call

    raw turbo_stream.replace('modal') {
      render detail_view.new(**detail, filters: @context)
    }

    raw turbo_stream.replace('stats_grid') {
      render StatsGridComponent.new(
        totals: @totals,
        month: @context[:month],
        year: @context[:year]
      )
    }
  end

  def render_failure(edit_view, record_kwargs)
    raw turbo_stream.replace('modal') {
      render edit_view.new(**record_kwargs, context: @context)
    }
  end
end

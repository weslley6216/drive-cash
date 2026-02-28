module TurboCreateResponse
  private

  def render_turbo_streams(record:, new_view:, record_key:)
    if record.persisted? && @totals
      render_success(record)
    else
      render_failure(new_view, record_key => record)
    end

    raw turbo_stream.update('flash') {
      render FlashComponent.new(flash: helpers.flash)
    }
  end

  def render_success(record)
    raw turbo_stream.update('modal', '')

    raw turbo_stream.replace('stats_grid') {
      render StatsGridComponent.new(
        totals: @totals,
        month: @context[:month],
        year: @context[:year]
      )
    }

    raw turbo_stream.replace('dashboard_filters') {
      render FilterComponent.new(
        selected_year: record.date.year,
        selected_month: record.date.month,
        available_years: Dashboard::StatsService.available_years
      )
    }
  end

  def render_failure(new_view, record_kwargs)
    raw turbo_stream.replace('modal') {
      render new_view.new(**record_kwargs, context: @context)
    }
  end
end

module RecordSaveResponse
  extend ActiveSupport::Concern

  private

  def turbo_success(view_class, **kwargs)
    record = kwargs.values.first
    context, totals = build_totals_context(record)
    flash.now[:notice] = t('.success')
    respond_to do |format|
      format.turbo_stream do
        render view_class.new(
          **kwargs,
          totals: totals,
          context: context,
          totals_context: dashboard_filter_context
        )
      end
    end
  end

  def turbo_error(view_class, **kwargs)
    record = kwargs.values.first
    context, _totals = build_totals_context(record)
    flash.now[:alert] = record.errors.full_messages.to_sentence
    respond_to do |format|
      format.turbo_stream do
        render view_class.new(**kwargs, totals: nil, context: context), status: :unprocessable_content
      end
    end
  end

  def turbo_render_list(detail_service, detail_view)
    filter  = dashboard_filter_context
    totals  = Dashboard::StatsService.new(**filter).call
    detail  = detail_service.new(year: filter[:year], month: filter[:month]).call
    today   = Dashboard::TodayService.new.call
    rows    = Dashboard::RecentActivityService.new(year: filter[:year], month: filter[:month]).call
    cats    = Dashboard::CategoryBreakdownService.new(year: filter[:year], month: filter[:month]).call
    monthly = filter[:month].present?
    flash.now[:notice] = t('.success')

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('modal', view_context.render(detail_view.new(**detail, filters: filter))),
          turbo_stream.replace('stats_grid', view_context.render(StatsGridComponent.new(totals: totals, month: filter[:month], year: filter[:year]))),
          turbo_stream.update('hero_profit_card', view_context.render(HeroProfitCardComponent.new(
            profit: totals[:profit],
            change_percent: totals[:change_percent],
            profit_per_day: totals[:profit_per_day],
            days_count: totals[:days],
            monthly_series: monthly ? totals[:daily_profit_series] : totals[:monthly_profit_series],
            year: filter[:year],
            month: filter[:month],
            daily_mode: monthly
          ))),
          turbo_stream.update('today_card', today ? view_context.render(TodayCardComponent.new(**today)) : ''),
          turbo_stream.update('recent_activity', view_context.render(RecentActivityComponent.new(rows: rows))),
          turbo_stream.update('category_breakdown', view_context.render(CategoryBreakdownComponent.new(categories: cats))),
          turbo_stream.update('flash_modal', view_context.render(FlashComponent.new(flash: flash, inline: true)))
        ]
      end
    end
  end

  def build_totals_context(record)
    context = dashboard_context(record)
    totals = Dashboard::StatsService.new(**context).call

    [context, totals]
  end

  def dashboard_filter_context
    {
      year:  params.dig(:context, :year).presence&.to_i || Date.current.year,
      month: params.dig(:context, :month).presence&.to_i
    }
  end
end

module RecordSaveResponse
  extend ActiveSupport::Concern

  private

  def turbo_success(view_class, **kwargs)
    record = kwargs.values.first
    context, totals = build_totals_context(record)
    flash[:notice] = t('.success')
    respond_to do |format|
      format.turbo_stream do
        render view_class.new(
          **kwargs,
          totals: totals,
          context: context
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
    filter = dashboard_context
    detail = detail_service.new(year: filter[:year], month: filter[:month]).call
    totals = Dashboard::StatsService.new(**filter).call
    flash[:notice] = t('.success')

    respond_to do |format|
      format.turbo_stream do
        render Dashboard::DeleteRefreshView.new(
          detail_view: detail_view.new(**detail, filters: filter),
          filter: filter,
          totals: totals
        )
      end
    end
  end

  def build_totals_context(record)
    context = dashboard_context(record)
    totals = Dashboard::StatsService.new(**context).call

    [context, totals]
  end
end

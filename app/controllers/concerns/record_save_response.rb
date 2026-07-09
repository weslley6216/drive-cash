module RecordSaveResponse
  extend ActiveSupport::Concern

  private

  def turbo_success(view_class, record:, record_key:, detail_service: nil, **extra)
    context, totals = build_totals_context(record)
    flash[:notice] = t('.success')
    detail = detail_service && record.persisted? ? { detail: detail_for(detail_service, context) } : {}
    respond_to do |format|
      format.turbo_stream do
        render view_class.new(record_key => record, totals: totals, context: context, **detail, **extra)
      end
    end
  end

  def turbo_error(view_class, record:, record_key:, **extra)
    context, _totals = build_totals_context(record)
    flash.now[:alert] = record.errors.full_messages.to_sentence
    respond_to do |format|
      format.turbo_stream do
        render view_class.new(record_key => record, totals: nil, context: context, **extra), status: :unprocessable_content
      end
    end
  end

  def turbo_render_list(detail_service, detail_view)
    filter = dashboard_context
    detail = detail_for(detail_service, filter)
    totals = Dashboard::StatsService.new(**filter, user: current_user).call
    flash[:notice] = t('.success')

    respond_to do |format|
      format.turbo_stream do
        render Dashboard::DeleteRefreshView.new(
          detail_view: detail_view.new(**detail, filters: filter),
          filter:      filter,
          totals:      totals
        )
      end
    end
  end

  def build_totals_context(record)
    context = dashboard_context(record)
    totals = Dashboard::StatsService.new(**context, user: current_user).call

    [context, totals]
  end

  def detail_for(detail_service, filter)
    detail_service.new(year: filter[:year], month: filter[:month], user: current_user).call
  end
end

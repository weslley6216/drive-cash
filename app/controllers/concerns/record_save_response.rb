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

  def build_totals_context(record)
    context = dashboard_context(record)
    totals  = Dashboard::StatsService.new(**dashboard_filter_context).call
    [context, totals]
  end

  def dashboard_filter_context
    {
      year:  params.dig(:context, :year).presence&.to_i || Date.current.year,
      month: params.dig(:context, :month).presence&.to_i
    }
  end
end

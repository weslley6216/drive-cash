module RecordSaveResponse
  extend ActiveSupport::Concern

  private

  def build_totals_context(record)
    context = dashboard_context(record)
    totals  = Dashboard::StatsService.new(**context).call
    [context, totals]
  end
end

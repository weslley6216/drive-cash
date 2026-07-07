class ExportsController < ApplicationController
  def index
    export = build_export
    render Exports::NewView.new(export: export, exports: current_user.exports.recent, summary_view: summary_view_for(export))
  end

  def create
    export = current_user.exports.new(export_attributes)

    if export.save
      ExportJob.perform_later(export.id)
      redirect_to exports_path, notice: t('exports.flash.enqueued')
    else
      render Exports::NewView.new(export: export, exports: current_user.exports.recent, summary_view: summary_view_for(export)),
             status: :unprocessable_content
    end
  end

  def show
    export = current_user.exports.find_by(id: params[:id])
    return head :not_found unless export
    return redirect_to(exports_path, alert: t('exports.flash.failed')) if export.status_failed?
    return redirect_to(exports_path, alert: t('exports.flash.not_ready')) unless export.status_done? && export.file.attached?

    redirect_to rails_blob_path(export.file, disposition: 'attachment')
  end

  def preview
    export = current_user.exports.new(preview_attributes)
    view = summary_view_for(export)

    render view, status: export.valid? ? :ok : :unprocessable_content
  end

  def row
    export = current_user.exports.find_by(id: params[:id])
    return head :not_found unless export

    render Exports::RecentRowView.new(export: export, last: true)
  end

  private

  def build_export
    current_user.exports.new(
      period_kind:  'year',
      period_start: Date.current.beginning_of_year,
      period_end:   Date.current.end_of_year,
      format:       'pdf'
    )
  end

  def summary_view_for(export)
    export.resolve_period
    payload = Exports::Builder.call(export: export)

    Exports::SummaryFrameView.new(payload: payload, period_label: Exports::RecentsName.new(export).call, format: export.format || 'pdf')
  end

  def export_attributes
    params.require(:export).permit(
      :period_kind, :period_start, :period_end, :format,
      includes: %i[earnings expenses refuelings maintenances]
    ).then { |attrs| attrs.merge(includes: normalize_includes(attrs[:includes])) }
  end

  def preview_attributes
    params.permit(export: [:period_kind, :period_start, :period_end, :format, includes: %i[earnings expenses refuelings maintenances]])
      .fetch(:export, {})
      .then { |attrs| attrs.merge(includes: normalize_includes(attrs[:includes])) }
  end

  def normalize_includes(payload)
    Export::INCLUDABLE.each_with_object({}) do |key, hash|
      hash[key] = ActiveModel::Type::Boolean.new.cast(payload&.dig(key.to_sym) || payload&.dig(key))
    end
  end
end

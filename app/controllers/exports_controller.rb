class ExportsController < ApplicationController
  def index
    @exports = current_user.exports.recent
    render Exports::NewView.new(export: build_export, exports: @exports)
  end

  def new
    render Exports::NewView.new(export: build_export, exports: current_user.exports.recent)
  end

  def create
    export = current_user.exports.new(export_attributes)

    if export.save
      ExportJob.perform_later(export.id)
      redirect_to exports_path, notice: t('exports.flash.enqueued')
    else
      render Exports::NewView.new(export: export, exports: current_user.exports.recent),
             status: :unprocessable_content
    end
  end

  def show
    export = current_user.exports.find_by(id: params[:id])
    return head :not_found unless export
    return redirect_to(exports_path, alert: t('exports.flash.not_ready')) unless export.status_done? && export.file.attached?

    redirect_to rails_blob_path(export.file, disposition: 'attachment')
  end

  def preview
    export = current_user.exports.new(preview_attributes)
    export.valid?
    payload = Exports::Builder.call(export: export)
    render Exports::SummaryFrameView.new(payload: payload, period_label: export.display_name, format: export.format)
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

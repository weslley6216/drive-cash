module ExportStreamResponse
  extend ActiveSupport::Concern

  private

  def respond_with_enqueued_export(export)
    respond_to do |format|
      format.turbo_stream { render Exports::CreateView.new(export: export) }
      format.html { redirect_to exports_path, notice: t('exports.flash.enqueued') }
    end
  end

  def respond_with_requeued_export(export)
    respond_to do |format|
      format.turbo_stream { render Exports::RetryView.new(export: export) }
      format.html { redirect_to exports_path, notice: t('exports.flash.enqueued') }
    end
  end
end

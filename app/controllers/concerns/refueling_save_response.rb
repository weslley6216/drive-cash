module RefuelingSaveResponse
  extend ActiveSupport::Concern

  private

  def respond_to_refueling_save(result, notice_key:)
    if result.success?
      flash[:notice] = refueling_notice(result, notice_key)
      respond_with_modal_refresh(html_redirect: vehicle_path)
    else
      @refueling = result.refueling
      flash.now[:alert] = @refueling.errors.full_messages.to_sentence
      render Refuelings::FormView.new(refueling: @refueling), status: :unprocessable_content
    end
  end

  def refueling_notice(result, notice_key)
    return t(notice_key) unless result.odometer_advanced

    t('refuelings.flash.odometer_synced', km: helpers.number_with_delimiter(result.refueling.odometer_km))
  end
end

module MarkDoneResponse
  extend ActiveSupport::Concern

  private

  def respond_with_mark_done(result)
    if result.success?
      flash[:undo] = {
        'category' => @maintenance.category,
        'km'       => result.request.done_km,
        'count'    => result.previous_km.size,
        'path'     => maintenance_mark_done_path(@maintenance),
        'restore'  => result.previous_km
      }
      respond_with_modal_refresh(html_redirect: vehicle_path)
    else
      render Maintenances::MarkDoneFormView.new(request: result.request), status: :unprocessable_content
    end
  end

  def respond_with_undo(restored)
    if restored
      flash[:notice] = t('maintenances.mark_done.undone')
    else
      flash[:alert] = t('maintenances.mark_done.undo_failed')
    end
    respond_with_refresh(html_redirect: vehicle_path)
  end
end

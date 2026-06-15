module ModalRefreshResponse
  extend ActiveSupport::Concern

  private

  def respond_with_modal_refresh(html_redirect:)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [turbo_stream.update('modal', ''), turbo_stream.refresh(request_id: nil)]
      end
      format.html { redirect_to html_redirect }
    end
  end

  def respond_with_refresh(html_redirect:)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      format.html { redirect_to html_redirect }
    end
  end
end

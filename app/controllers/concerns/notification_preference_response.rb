module NotificationPreferenceResponse
  extend ActiveSupport::Concern
  include ModalRefreshResponse

  private

  def respond_with_preference_update(result)
    return head :unprocessable_content unless result.success?

    flash[:muted] = { 'kind' => result.kind } unless result.enabled
    respond_with_refresh(html_redirect: edit_notification_preferences_path)
  end
end

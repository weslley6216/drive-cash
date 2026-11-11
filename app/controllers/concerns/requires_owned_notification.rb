module RequiresOwnedNotification
  extend ActiveSupport::Concern

  included do
    before_action :require_owned_notification, only: %i[open destroy]
  end

  private

  def require_owned_notification
    @notification = current_user.notifications.find_by(id: params[:id])
    head :not_found unless @notification
  end
end

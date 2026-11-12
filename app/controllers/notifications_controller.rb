class NotificationsController < ApplicationController
  include RequiresOwnedNotification

  def index
    Notifications::Sweeper.new(user: current_user).call
    render Notifications::IndexView.new(
      groups:       Notifications::Grouping.new(current_user.visible_notifications.recent).call,
      unread_count: current_user.visible_notifications.unread.count
    )
  end

  def open
    @notification.mark_read!
    redirect_to Notifications::Presenters.present(@notification).destination(params[:via]), status: :see_other
  end

  def destroy
    @notification.dismiss!
    respond_with_refresh(html_redirect: notifications_path)
  end

  def read_all
    current_user.notifications.unread.mark_all_read!
    respond_with_refresh(html_redirect: notifications_path)
  end

  def clear
    current_user.visible_notifications.read.dismiss_all!
    respond_with_refresh(html_redirect: notifications_path)
  end
end

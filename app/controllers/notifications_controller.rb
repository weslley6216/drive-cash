class NotificationsController < ApplicationController
  before_action :find_notification, only: :read

  def index
    Notifications::Sweeper.new(user: current_user).call
    render Notifications::IndexView.new(
      groups:       Notifications::Grouping.new(current_user.notifications.recent).call,
      unread_count: current_user.notifications.unread.count
    )
  end

  def read
    @notification.mark_read!
    respond_with_refresh(html_redirect: notifications_path)
  end

  def read_all
    current_user.notifications.unread.mark_all_read!
    respond_with_refresh(html_redirect: notifications_path)
  end

  private

  def find_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end

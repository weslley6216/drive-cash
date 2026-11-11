class NotificationPreferencesController < ApplicationController
  include NotificationPreferenceResponse

  def edit
    render NotificationPreferences::EditView.new(rows: Notifications::PreferenceRows.call(current_user.notification_settings))
  end

  def update
    result = Notifications::PreferenceUpdater.call(user: current_user, kind: params[:kind], enabled: params[:enabled])
    respond_with_preference_update(result)
  end
end

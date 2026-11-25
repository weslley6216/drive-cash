class ReauthenticationsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_reauthentication_path, alert: I18n.t('reauthentications.rate_limit') }

  def new
    render Reauthentications::NewView.new(unread_count: current_user.unread_notifications_count)
  end

  def create
    if current_user.authenticate(params[:password])
      Current.session.reauthenticate!
      redirect_to edit_profile_path
    else
      render Reauthentications::NewView.new(unread_count: current_user.unread_notifications_count, error: true), status: :unprocessable_content
    end
  end
end

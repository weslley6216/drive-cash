class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create oauth_callback oauth_failure]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_url, alert: I18n.t('sessions.rate_limit') }

  before_action :redirect_if_authenticated, only: :new

  def new
    render Sessions::NewView.new
  end

  def create
    if (user = User.authenticate_by(email_address: params[:email_address], password: params[:password]))
      start_new_session_for(user, remember_me: params[:remember_me] == '1')
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: I18n.t('sessions.invalid_credentials')
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  def oauth_callback
    auth = request.env['omniauth.auth']
    user = User.find_or_create_from_oauth(auth)
    start_new_session_for(user, remember_me: true)
    redirect_to after_authentication_url
  end

  def oauth_failure
    redirect_to new_session_path, alert: I18n.t('sessions.oauth_failure')
  end

  private

  def redirect_if_authenticated
    redirect_to root_path if find_session_by_cookie
  end
end

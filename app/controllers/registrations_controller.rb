class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_authenticated, only: %i[new create]

  def new
    render Registrations::NewView.new(user: User.new)
  end

  def create
    user = User.new(registration_params)
    if user.save
      start_new_session_for(user, remember_me: true)
      redirect_to root_path, notice: I18n.t('registrations.welcome')
    else
      render Registrations::NewView.new(user: user), status: :unprocessable_content
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end

  def redirect_if_authenticated
    redirect_to root_path, notice: I18n.t('registrations.already_signed_in') if find_session_by_cookie
  end
end

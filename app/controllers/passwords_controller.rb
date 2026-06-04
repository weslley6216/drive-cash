class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]

  def new
    render Passwords::NewView.new
  end

  def create
    user = User.find_by(email_address: params[:email_address].to_s.strip.downcase)
    PasswordsMailer.reset(user).deliver_later if user

    redirect_to new_session_path, notice: I18n.t('passwords.instructions_sent')
  end

  def edit
    render Passwords::EditView.new(token: params[:token])
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      redirect_to new_session_path, notice: I18n.t('passwords.updated')
    else
      redirect_to edit_password_path(params[:token]), alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: I18n.t('passwords.not_found')
  end
end

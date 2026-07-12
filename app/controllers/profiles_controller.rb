class ProfilesController < ApplicationController
  def edit
    render Profiles::EditView.new(user: current_user)
  end

  def update
    current_user.assign_attributes(profile_params)

    if current_user.save(context: :profile_update)
      redirect_to edit_profile_path, notice: t('profiles.flash.saved')
    else
      render Profiles::EditView.new(user: current_user), status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email_address, :phone, :current_password, :password, :password_confirmation)
  end
end

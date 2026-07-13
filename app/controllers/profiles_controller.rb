class ProfilesController < ApplicationController
  def edit
    render Profiles::EditView.new(user: current_user, reauthenticated: reauthenticated?)
  end

  def update
    current_user.assign_attributes(profile_params)

    return redirect_to new_reauthentication_path if current_user.changing_credentials? && !reauthenticated?

    if current_user.save
      redirect_to edit_profile_path, notice: t('profiles.flash.saved')
    else
      render Profiles::EditView.new(user: current_user, reauthenticated: reauthenticated?), status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email_address, :phone, :password, :password_confirmation)
  end
end

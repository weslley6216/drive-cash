class AccountController < ApplicationController
  def show
    render Account::ShowView.new(user: current_user, vehicle: current_user.vehicle)
  end
end

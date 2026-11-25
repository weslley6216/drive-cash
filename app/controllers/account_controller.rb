class AccountController < ApplicationController
  def show
    render Account::ShowView.new(user: current_user, vehicle: current_user.vehicle, unread_count: current_user.unread_notifications_count)
  end
end

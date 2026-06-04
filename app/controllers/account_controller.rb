class AccountController < ApplicationController
  def show
    render Account::ShowView.new(user: current_user)
  end
end

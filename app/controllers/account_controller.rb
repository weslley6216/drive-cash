class AccountController < ApplicationController
  def show
    render Account::ShowView.new(user: Current.user)
  end
end

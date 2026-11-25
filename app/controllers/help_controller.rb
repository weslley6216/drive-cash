class HelpController < ApplicationController
  def show
    render Help::ShowView.new(unread_count: current_user.unread_notifications_count)
  end
end

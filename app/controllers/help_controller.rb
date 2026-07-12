class HelpController < ApplicationController
  def show
    render Help::ShowView.new
  end
end

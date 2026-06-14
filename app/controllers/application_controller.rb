class ApplicationController < ActionController::Base
  include Authentication
  include DashboardContext
  include RecordParams
  include RecordSaveResponse
  include ModalRefreshResponse

  allow_browser versions: :modern

  stale_when_importmap_changes

  layout false

  def coming_soon
    render Application::ComingSoonView.new
  end

  private

  def current_user = Current.user
end

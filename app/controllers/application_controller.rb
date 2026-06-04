class ApplicationController < ActionController::Base
  include Authentication
  include DashboardContext
  include RecordSaveResponse

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout false

  def coming_soon
    render Application::ComingSoonView.new
  end

  private

  def current_user = Current.user
end

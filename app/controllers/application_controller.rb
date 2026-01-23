class ApplicationController < ActionController::Base
  include DashboardContext

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout false

  def context_year = params.dig(:context, :year).presence&.to_i || Date.current.year
end

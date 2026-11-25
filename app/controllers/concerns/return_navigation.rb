module ReturnNavigation
  extend ActiveSupport::Concern

  included do
    helper_method :return_path
  end

  private

  def return_path(fallback:) = url_from(params[:return_to]) || fallback
end

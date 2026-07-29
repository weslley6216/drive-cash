module RequiresOwnedExport
  extend ActiveSupport::Concern

  included do
    before_action :require_owned_export, only: %i[show row retry]
  end

  private

  def require_owned_export
    @export = current_user.exports.find_by(id: params[:id])
    head :not_found unless @export
  end
end

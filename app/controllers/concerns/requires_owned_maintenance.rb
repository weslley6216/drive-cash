module RequiresOwnedMaintenance
  extend ActiveSupport::Concern

  included do
    before_action :require_owned_maintenance
  end

  private

  def require_owned_maintenance
    @maintenance = current_user.vehicle.maintenances.find_by(id: params[:maintenance_id])
    head :not_found unless @maintenance
  end
end

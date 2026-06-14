module RequiresVehicle
  extend ActiveSupport::Concern

  included do
    before_action :require_vehicle
  end

  private

  def require_vehicle
    redirect_to vehicle_path unless current_user.vehicle
  end
end

class VehiclesController < ApplicationController
  def show
    @vehicle = current_user.vehicle
    if @vehicle
      payload = Vehicle::MaintenanceService.new(user: current_user).call
      render Vehicle::ShowView.new(payload: payload)
    else
      render Vehicle::ShowView.new(payload: empty_payload, vehicle_form: current_user.build_vehicle)
    end
  end

  def update
    @vehicle = current_user.vehicle || current_user.build_vehicle

    if @vehicle.update(vehicle_params)
      flash[:notice] = t('vehicle.flash.updated')
      redirect_to vehicle_path
    else
      payload = current_user.vehicle ? Vehicle::MaintenanceService.new(user: current_user).call : empty_payload
      render Vehicle::ShowView.new(payload: payload, vehicle_form: @vehicle), status: :unprocessable_content
    end
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:brand, :vehicle_model, :year, :license_plate, :odometer_km)
  end

  def empty_payload
    {
      vehicle: nil,
      odometer: { current_km: 0, km_this_month: 0 },
      metrics: { cost_per_km: 0, revenue_per_km: 0, profit_per_km: 0, km_per_liter: nil },
      upcoming_maintenances: [],
      recent_refuelings: [],
      insights: []
    }
  end
end

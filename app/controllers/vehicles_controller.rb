class VehiclesController < ApplicationController
  def show
    @vehicle = current_user.vehicle
    if @vehicle
      payload = Vehicles::MaintenanceService.new(user: current_user).call
        .merge(tank: Vehicles::TankBalanceService.new(user: current_user).call)
      render Vehicles::ShowView.new(payload: payload)
    else
      empty = Vehicles::MaintenanceService::EMPTY_PAYLOAD.merge(tank: Vehicles::TankBalanceService::EMPTY)
      render Vehicles::ShowView.new(payload: empty, vehicle_form: current_user.build_vehicle)
    end
  end

  def edit
    @vehicle = current_user.vehicle || current_user.build_vehicle
    render Vehicles::EditView.new(vehicle: @vehicle)
  end

  def update
    @vehicle = current_user.vehicle || current_user.build_vehicle
    odometer_changed = vehicle_params[:odometer_km].present? && vehicle_params[:odometer_km].to_i != @vehicle.odometer_km
    attributes = odometer_changed ? vehicle_params.merge(odometer_updated_at: Time.current) : vehicle_params

    if @vehicle.update(attributes)
      flash[:notice] = t('vehicle.flash.updated')
      respond_with_modal_refresh(html_redirect: vehicle_path)
    else
      payload = if @vehicle.persisted?
                  Vehicles::MaintenanceService.new(user: current_user).call
                    .merge(tank: Vehicles::TankBalanceService.new(user: current_user).call)
      else
                  Vehicles::MaintenanceService::EMPTY_PAYLOAD.merge(tank: Vehicles::TankBalanceService::EMPTY)
      end
      render Vehicles::ShowView.new(payload: payload, vehicle_form: @vehicle), status: :unprocessable_content
    end
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:brand, :vehicle_model, :year, :license_plate, :odometer_km)
  end
end

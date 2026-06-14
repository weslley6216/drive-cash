class VehiclesController < ApplicationController
  def show
    @vehicle = current_user.vehicle
    if @vehicle
      render Vehicles::ShowView.new(payload: dashboard_payload)
    else
      render Vehicles::ShowView.new(payload: empty_payload, vehicle_form: current_user.build_vehicle)
    end
  end

  def edit
    @vehicle = current_user.vehicle || current_user.build_vehicle
    render Vehicles::EditView.new(vehicle: @vehicle)
  end

  def update
    @vehicle = current_user.vehicle || current_user.build_vehicle
    attributes = odometer_changed? ? vehicle_params.merge(odometer_updated_at: Time.current) : vehicle_params

    if @vehicle.update(attributes)
      flash[:notice] = t('vehicle.flash.updated')
      respond_with_modal_refresh(html_redirect: vehicle_path)
    else
      payload = current_user.vehicle ? dashboard_payload : empty_payload
      render Vehicles::ShowView.new(payload: payload, vehicle_form: @vehicle), status: :unprocessable_content
    end
  end

  private

  def dashboard_payload
    Vehicles::MaintenanceService.new(user: current_user).call
      .merge(tank: Vehicles::TankBalanceService.new(user: current_user).call)
  end

  def empty_payload
    Vehicles::MaintenanceService::EMPTY_PAYLOAD.merge(tank: Vehicles::TankBalanceService::EMPTY)
  end

  def odometer_changed?
    vehicle_params[:odometer_km].present? && vehicle_params[:odometer_km].to_i != @vehicle.odometer_km
  end

  def vehicle_params
    params.require(:vehicle).permit(:brand, :vehicle_model, :year, :license_plate, :odometer_km)
  end
end

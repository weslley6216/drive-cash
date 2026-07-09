class VehiclesController < ApplicationController
  def show
    @vehicle = current_user.vehicle
    if @vehicle
      render Vehicles::ShowView.new(payload: show_payload)
    else
      render Vehicles::ShowView.new(payload: show_payload, vehicle_form: current_user.build_vehicle)
    end
  end

  def edit
    @vehicle = current_user.vehicle || current_user.build_vehicle
    render Vehicles::EditView.new(vehicle: @vehicle)
  end

  def update
    @vehicle = current_user.vehicle || current_user.build_vehicle

    if @vehicle.update(vehicle_params)
      flash[:notice] = t('vehicle.flash.updated')
      respond_with_modal_refresh(html_redirect: vehicle_path)
    else
      render Vehicles::ShowView.new(payload: show_payload, vehicle_form: @vehicle), status: :unprocessable_content
    end
  end

  private

  def show_payload
    if @vehicle&.persisted?
      Vehicles::MaintenanceService.new(user: current_user).call
        .merge(tank: Vehicles::TankBalanceService.new(user: current_user).call)
    else
      Vehicles::MaintenanceService::EMPTY_PAYLOAD.merge(tank: Vehicles::TankBalanceService::EMPTY)
    end
  end

  def vehicle_params
    params.require(:vehicle).permit(:brand, :vehicle_model, :year, :license_plate, :odometer_km)
  end
end

class VehiclesController < ApplicationController
  def show
    @vehicle = current_user.vehicle
    if @vehicle
      payload = Vehicles::MaintenanceService.new(user: current_user).call
      render Vehicles::ShowView.new(payload: payload)
    else
      render Vehicles::ShowView.new(payload: Vehicles::MaintenanceService::EMPTY_PAYLOAD, vehicle_form: current_user.build_vehicle)
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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [turbo_stream.update('modal', ''), turbo_stream.refresh(request_id: nil)]
        end
        format.html { redirect_to vehicle_path }
      end
    else
      payload = current_user.vehicle ? Vehicles::MaintenanceService.new(user: current_user).call : Vehicles::MaintenanceService::EMPTY_PAYLOAD
      render Vehicles::ShowView.new(payload: payload, vehicle_form: @vehicle), status: :unprocessable_content
    end
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:brand, :vehicle_model, :year, :license_plate, :odometer_km)
  end
end

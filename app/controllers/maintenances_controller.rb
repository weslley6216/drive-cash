class MaintenancesController < ApplicationController
  before_action :require_vehicle
  before_action :find_maintenance, only: %i[edit update destroy mark_done]

  def new
    @maintenance = current_user.vehicle.maintenances.new(category: :oil_change)
    render Maintenances::FormView.new(maintenance: @maintenance)
  end

  def create
    @maintenance = current_user.vehicle.maintenances.new(maintenance_params).apply_catalog_defaults

    if @maintenance.save
      flash[:notice] = t('maintenances.flash.created')
      respond_with_refresh
    else
      flash.now[:alert] = @maintenance.errors.full_messages.to_sentence
      render Maintenances::FormView.new(maintenance: @maintenance), status: :unprocessable_content
    end
  end

  def edit
    render Maintenances::FormView.new(maintenance: @maintenance)
  end

  def update
    if @maintenance.update(maintenance_params)
      flash[:notice] = t('maintenances.flash.updated')
      respond_with_refresh
    else
      flash.now[:alert] = @maintenance.errors.full_messages.to_sentence
      render Maintenances::FormView.new(maintenance: @maintenance), status: :unprocessable_content
    end
  end

  def mark_done
    @maintenance.update(last_done_km: current_user.vehicle.odometer_km)
    flash[:notice] = t('maintenances.flash.marked_done')
    respond_with_refresh
  end

  def destroy
    @maintenance.destroy
    flash[:notice] = t('maintenances.flash.destroyed')
    redirect_to vehicle_path
  end

  private

  def require_vehicle
    redirect_to vehicle_path unless current_user.vehicle
  end

  def find_maintenance
    @maintenance = current_user.vehicle.maintenances.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def maintenance_params
    params.require(:maintenance).permit(:category, :last_done_km, :interval_km, :estimated_cost)
  end

  def respond_with_refresh
    respond_to do |format|
      format.turbo_stream { render turbo_stream: [turbo_stream.update('modal', ''), turbo_stream.refresh(request_id: nil)] }
      format.html { redirect_to vehicle_path }
    end
  end
end

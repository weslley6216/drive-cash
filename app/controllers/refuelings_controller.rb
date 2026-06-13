class RefuelingsController < ApplicationController
  before_action :require_vehicle
  before_action :find_refueling, only: %i[edit update destroy]

  def new
    @refueling = current_user.vehicle.refuelings.new(date: Date.current, full_tank: true)
    render Refuelings::FormView.new(refueling: @refueling)
  end

  def create
    @refueling = current_user.vehicle.refuelings.new(refueling_params)

    if @refueling.save
      flash[:notice] = t('refuelings.flash.created')
      respond_with_refresh
    else
      flash.now[:alert] = @refueling.errors.full_messages.to_sentence
      render Refuelings::FormView.new(refueling: @refueling), status: :unprocessable_content
    end
  end

  def edit
    render Refuelings::FormView.new(refueling: @refueling)
  end

  def update
    if @refueling.update(refueling_params)
      flash[:notice] = t('refuelings.flash.updated')
      respond_with_refresh
    else
      flash.now[:alert] = @refueling.errors.full_messages.to_sentence
      render Refuelings::FormView.new(refueling: @refueling), status: :unprocessable_content
    end
  end

  def destroy
    @refueling.destroy
    flash[:notice] = t('refuelings.flash.destroyed')
    redirect_to vehicle_path
  end

  private

  def require_vehicle
    redirect_to vehicle_path unless current_user.vehicle
  end

  def find_refueling
    @refueling = current_user.vehicle.refuelings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def refueling_params
    params.require(:refueling).permit(:date, :vendor, :liters, :total_amount, :odometer_km, :full_tank)
  end

  def respond_with_refresh
    respond_to do |format|
      format.turbo_stream { render turbo_stream: [turbo_stream.update('modal', ''), turbo_stream.refresh(request_id: nil)] }
      format.html { redirect_to vehicle_path }
    end
  end
end

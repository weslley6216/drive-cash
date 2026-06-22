class RefuelingsController < ApplicationController
  include RequiresVehicle

  before_action :find_refueling, only: %i[edit update destroy]

  def index
    cadence = Vehicles::TankCadence.new(user: current_user).call
    render Refuelings::IndexView.new(moves: Refuelings::Moves.call(user: current_user), cadence: cadence)
  end

  def new
    @refueling = current_user.vehicle.refuelings.new(date: Date.current, full_tank: true)
    render Refuelings::FormView.new(refueling: @refueling)
  end

  def create
    @refueling = current_user.vehicle.refuelings.new(refueling_params)

    if @refueling.save
      Vehicles::OdometerSync.new(vehicle: @refueling.vehicle, reading_km: @refueling.odometer_km, on: @refueling.date).call
      flash[:notice] = t('refuelings.flash.created')
      respond_with_modal_refresh(html_redirect: vehicle_path)
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
      Vehicles::OdometerSync.new(vehicle: @refueling.vehicle, reading_km: @refueling.odometer_km, on: @refueling.date).call
      flash[:notice] = t('refuelings.flash.updated')
      respond_with_modal_refresh(html_redirect: vehicle_path)
    else
      flash.now[:alert] = @refueling.errors.full_messages.to_sentence
      render Refuelings::FormView.new(refueling: @refueling), status: :unprocessable_content
    end
  end

  def destroy
    @refueling.destroy
    flash[:notice] = t('refuelings.flash.destroyed')
    respond_with_refresh(html_redirect: vehicle_path)
  end

  private

  def find_refueling
    @refueling = current_user.vehicle.refuelings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def refueling_params
    params.require(:refueling).permit(:date, :vendor, :liters, :total_amount, :odometer_km, :full_tank)
  end
end

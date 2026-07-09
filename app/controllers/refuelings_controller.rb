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
    result = Refuelings::Creator.call(vehicle: current_user.vehicle, params: refueling_params)
    handle_refueling_result(result, notice_key: 'refuelings.flash.created')
  end

  def edit
    render Refuelings::FormView.new(refueling: @refueling)
  end

  def update
    result = Refuelings::Updater.call(refueling: @refueling, params: refueling_params)
    handle_refueling_result(result, notice_key: 'refuelings.flash.updated')
  end

  def destroy
    @refueling.destroy
    flash[:notice] = t('refuelings.flash.destroyed')
    respond_with_refresh(html_redirect: vehicle_path)
  end

  private

  def handle_refueling_result(result, notice_key:)
    if result.success?
      flash[:notice] = t(notice_key)
      respond_with_modal_refresh(html_redirect: vehicle_path)
    else
      @refueling = result.refueling
      flash.now[:alert] = @refueling.errors.full_messages.to_sentence
      render Refuelings::FormView.new(refueling: @refueling), status: :unprocessable_content
    end
  end

  def find_refueling
    @refueling = current_user.vehicle.refuelings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def refueling_params
    params.require(:refueling).permit(:date, :vendor, :liters, :total_amount, :odometer_km, :full_tank)
  end
end

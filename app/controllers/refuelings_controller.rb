class RefuelingsController < ApplicationController
  include RequiresVehicle
  include RefuelingSaveResponse

  before_action :find_refueling, only: %i[edit update destroy]

  def index
    render Refuelings::IndexView.new(cycles: Refuelings::TankCycles.call(moves: Refuelings::Moves.call(user: current_user)),
                                     vehicle: current_user.vehicle, unread_count: current_user.unread_notifications_count)
  end

  def new
    @refueling = Refuelings::Prefill.call(user: current_user)
    render Refuelings::FormView.new(refueling: @refueling)
  end

  def create
    result = Refuelings::Creator.call(vehicle: current_user.vehicle, params: refueling_params)
    respond_to_refueling_save(result, notice_key: 'refuelings.flash.created')
  end

  def edit
    render Refuelings::FormView.new(refueling: @refueling)
  end

  def update
    result = Refuelings::Updater.call(refueling: @refueling, params: refueling_params)
    respond_to_refueling_save(result, notice_key: 'refuelings.flash.updated')
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

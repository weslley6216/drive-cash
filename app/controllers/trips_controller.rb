class TripsController < ApplicationController
  def new
    @trip = Trip.new(
      date: Date.current,
      route_value: 0.0,
      fuel_cost: 0.0,
      maintenance_cost: 0.0,
      other_costs: 0.0
    )

    render Trips::NewView.new(
      trip: @trip,
      context: params[:context]
    )
  end

  def create
    @trip = Trip.new(trip_params)

    if @trip.save
      @view_context, @totals = build_totals_context(@trip)

      flash.now[:notice] = t('.success')

      respond_to do |format|
        format.turbo_stream do
          render Trips::CreateView.new(
            trip: @trip,
            totals: @totals,
            context: @view_context
          )
        end
      end
    else
      @view_context, _totals = build_totals_context(@trip)
      flash.now[:alert] = t('.error', errors: @trip.errors.full_messages.to_sentence)

      respond_to do |format|
        format.turbo_stream do
          render Trips::CreateView.new(
            trip: @trip,
            totals: nil,
            context: @view_context
          )
        end
      end
    end
  end

  private

  def trip_params
    params.require(:trip).permit(
      :date,
      :route_value,
      :fuel_cost,
      :fuel_vendor,
      :maintenance_cost,
      :other_costs,
      :platform,
      :notes
    )
  end
end

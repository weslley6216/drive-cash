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
      @view_context = dashboard_context(@trip)
      @totals = Dashboard::StatsService.new(**@view_context).call
      
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
      @view_context = dashboard_context(@trip)
      flash.now[:alert] = "Erro ao salvar: #{@trip.errors.full_messages.to_sentence}"

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
      :maintenance_cost,
      :other_costs,
      :platform,
      :notes
    )
  end
end

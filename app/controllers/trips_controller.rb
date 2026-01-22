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
      context_year = params.dig(:context, :year).presence&.to_i || Date.current.year
      @totals = Dashboard::StatsService.new(year: context_year).call

      flash.now[:notice] = "Lançamento salvo com sucesso!"
      
      respond_to do |format|
        format.turbo_stream do
          render Trips::CreateView.new(trip: @trip, totals: @totals)
        end
      end
    else
      flash.now[:alert] = "Erro ao salvar: #{@trip.errors.full_messages.to_sentence}"
      
      respond_to do |format|
        format.turbo_stream do
          render Trips::CreateView.new(trip: @trip, totals: nil)
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

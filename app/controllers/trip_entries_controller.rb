class TripEntriesController < ApplicationController
  def new
    @trip_entry = TripEntry.new(date: Date.current)

    render TripEntries::NewView.new(
      trip_entry: @trip_entry,
      context: params[:context]
    )
  end

  def create
    @trip_entry = TripEntry.new(trip_entry_params)

    if @trip_entry.save
      context_year = params.dig(:context, :year).presence&.to_i || Date.current.year
      context_month = params.dig(:context, :month).presence&.to_i

      @totals = Dashboard::StatsService.new(
        year: Date.current.year
      ).call

      flash.now[:notice] = t('.success')
    else
      flash.now[:alert] = t('.error', errors: @trip_entry.errors.full_messages.join(', '))
    end

    respond_to do |format|
      format.turbo_stream do
        render TripEntries::CreateView.new(
          trip_entry: @trip_entry,
          totals: @totals
        )
      end
    end
  end

  private

  def trip_entry_params
    params.require(:trip_entry).permit(
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

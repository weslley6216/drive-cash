class DeliveriesController < ApplicationController
  def new
    @delivery = Delivery.new

    render Deliveries::NewView.new(delivery: @delivery)
  end

  def create
    @delivery = Delivery.new(delivery_params)

    if @delivery.save
      relation = Delivery.for_year(Date.current.year).chronological
      @totals = DashboardService.new(relation).call
      flash.now[:notice] = t('deliveries.create.success')
    else
      flash.now[:alert] = t('deliveries.create.error', errors: @delivery.errors.full_messages.join(', '))
    end

    respond_to do |format|
      format.turbo_stream do
        render Deliveries::CreateView.new(delivery: @delivery, totals: @totals)
      end
    end
  end

  private

  def delivery_params
    params.require(:delivery).permit(
      :date,
      :route_value,
      :fuel_cost,
      :maintenance_cost,
      :other_costs
    )
  end
end

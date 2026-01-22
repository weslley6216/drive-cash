module Trips
  class CreateView < ApplicationComponent
    def initialize(trip:, totals:, context: {})
      @trip = trip
      @totals = totals
      @context = context
    end

    def view_template
      if @trip.valid? && @totals
        raw turbo_stream.update('modal', '')
        raw turbo_stream.replace('stats_grid') {
          render StatsGridComponent.new(totals: @totals)
        }
      else
        raw turbo_stream.replace('modal') {
          render Trips::NewView.new(trip: @trip, context: @context)
        }
      end

      raw turbo_stream.update('flash') {
        render FlashComponent.new(flash: helpers.flash)
      }
    end
  end
end

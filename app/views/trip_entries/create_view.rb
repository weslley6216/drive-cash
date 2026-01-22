module TripEntries
  class CreateView < ApplicationComponent
    def initialize(trip_entry:, totals:, context: {})
      @trip_entry = trip_entry
      @totals = totals
      @context = context
    end

    def view_template
      if @trip_entry.valid? && @totals
        raw turbo_stream.update('modal', '')
        raw turbo_stream.replace('stats_grid') {
          render StatsGridComponent.new(totals: @totals)
        }
      else
        raw turbo_stream.replace('modal') {
          render TripEntries::NewView.new(trip_entry: @trip_entry, context: @context)
        }
      end

      raw turbo_stream.update('flash') {
        render FlashComponent.new(flash: helpers.flash)
      }
    end
  end
end

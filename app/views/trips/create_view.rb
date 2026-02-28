module Trips
  class CreateView < ApplicationView
    include TurboCreateResponse

    def initialize(trip:, totals:, context: {})
      @trip = trip
      @totals = totals
      @context = context || {}
    end

    def view_template
      render_turbo_streams(record: @trip, new_view: Trips::NewView, record_key: :trip)
    end
  end
end

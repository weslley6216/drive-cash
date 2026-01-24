module Trips
  class CreateView < ApplicationView
    def initialize(trip:, totals:, context: {})
      @trip = trip
      @totals = totals
      @context = context
    end

    def view_template
      if @trip.persisted? && @totals
        raw turbo_stream.update('modal', '')

        raw turbo_stream.replace('stats_grid') {
          render StatsGridComponent.new(
            totals: @totals,
            month: @context[:month],
            year: @context[:year]
          )
        }

        raw turbo_stream.replace('dashboard_filters') {
          render FilterComponent.new(
            selected_year: @trip.date.year,
            selected_month: @trip.date.month,
            available_years: Dashboard::StatsService.available_years
          )
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

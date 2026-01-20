module Deliveries
  class CreateView < ApplicationComponent
    def initialize(delivery:, totals:)
      @delivery = delivery
      @totals = totals
    end

    def view_template
      if @delivery.persisted?
        raw turbo_stream.update('modal', '')
        raw turbo_stream.replace('stats_grid') {
          render StatsGridComponent.new(totals: @totals)
        }
      else
        raw turbo_stream.replace('modal') {
          render Deliveries::NewView.new(delivery: @delivery)
        }
      end

      raw turbo_stream.update('flash') {
        render FlashComponent.new(flash: helpers.flash)
      }
    end
  end
end

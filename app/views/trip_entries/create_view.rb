# app/views/trip_entries/create_view.rb
module TripEntries
  class CreateView < ApplicationComponent
    def initialize(trip_entry:, totals:)
      @trip_entry = trip_entry
      @totals = totals
    end

    def view_template
      if @trip_entry.valid? && @totals
        # Sucesso - fecha modal e atualiza stats
        raw turbo_stream.update('modal', '')
        raw turbo_stream.replace('stats_grid') {
          render StatsGridComponent.new(totals: @totals)
        }
      else
        # Erro - re-renderiza form com erros
        raw turbo_stream.replace('modal') {
          render TripEntries::NewView.new(trip_entry: @trip_entry)
        }
      end

      # Sempre atualiza flash
      raw turbo_stream.update('flash') {
        render FlashComponent.new(flash: helpers.flash)
      }
    end
  end
end

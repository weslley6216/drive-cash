module TurboSaveStreams
  private

  def stats_grid_stream(totals:, month:, year:)
    raw turbo_stream.replace('stats_grid') {
      render StatsGridComponent.new(totals: totals, month: month, year: year)
    }
  end

  def flash_stream(target = 'flash', inline: false)
    raw turbo_stream.update(target) {
      render FlashComponent.new(flash: helpers.flash, inline: inline)
    }
  end

  def modal_stream(view)
    raw turbo_stream.replace('modal') { render view }
  end

  def clear_modal_stream
    raw turbo_stream.update('modal', '')
  end
end

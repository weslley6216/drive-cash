module TurboSaveStreams
  private

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

  def refresh_stream
    raw '<turbo-stream action="refresh"></turbo-stream>'.html_safe
  end
end

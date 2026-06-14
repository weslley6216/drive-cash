class FlashComponent < ApplicationComponent
  def initialize(flash:, inline: false)
    @flash = flash
    @inline = inline
  end

  def view_template
    return if @flash.empty?
    return render_inline if @inline

    render_fixed
  end

  private

  def render_fixed
    div(id: 'flash', class: 'fixed top-4 right-4 z-50 flex flex-col gap-2') do
      @flash.each { |type, message| flash_message(type, message) }
    end
  end

  def render_inline
    div(id: 'flash_modal', class: 'absolute top-4 left-4 right-4 z-10') do
      @flash.each { |type, message| flash_message(type, message) }
    end
  end

  def flash_message(type, message)
    div(
      class: flash_classes(type),
      data:  { controller: 'flash' },
      style: 'transition: opacity 0.6s ease, transform 0.6s ease;'
    ) { message }
  end

  def flash_classes(type)
    base = 'px-4 py-3 rounded-lg shadow text-white animate-slide-down text-sm'
    "#{base} #{flash_color(type)}"
  end

  def flash_color(type)
    case type.to_sym
    when :notice, :success then 'bg-green-600'
    when :alert, :error    then 'bg-red-600'
    else 'bg-blue-600'
    end
  end
end

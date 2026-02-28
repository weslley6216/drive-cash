class FlashComponent < ApplicationComponent
  def initialize(flash:)
    @flash = flash
  end

  def view_template
    return if @flash.empty?

    div(id: 'flash', class: 'fixed top-4 right-4 z-50 flex flex-col gap-2') do
      @flash.each do |type, message|
        flash_message(type, message)
      end
    end
  end

  private

  def flash_message(type, message)
    div(
      class: flash_classes(type),
      data: { controller: 'flash' },
      style: 'transition: opacity 0.6s ease, transform 0.6s ease;'
    ) { message }
  end

  def flash_classes(type)
    base_classes = 'px-6 py-3 rounded-lg shadow-lg text-white animate-slide-down'
    color_class = flash_color(type)

    "#{base_classes} #{color_class}"
  end

  def flash_color(type)
    case type.to_sym
    when :notice, :success then 'bg-green-600'
    when :alert, :error then 'bg-red-600'
    else 'bg-blue-600'
    end
  end
end

class WidgetComponent < ApplicationComponent
  COLORS = {
    green: { bg: 'bg-green-50', text: 'text-green-900' },
    red:   { bg: 'bg-red-50', text: 'text-red-900' }
  }.freeze

  def initialize(title:, value:, color: :green)
    @title = title
    @value = value
    @color = color
  end

  def view_template
    div(class: card_classes) do
      p(class: 'text-sm font-medium opacity-75') { @title }
      p(class: value_classes) { format_currency(@value) }
    end
  end

  private

  def card_classes
    class_names('rounded-xl p-3 border shadow-sm', colors[:bg])
  end

  def value_classes
    class_names('text-xl font-bold mt-1', colors[:text])
  end

  def colors
    @colors ||= COLORS.fetch(@color, default_colors)
  end

  def default_colors
    { bg: 'bg-white', text: 'text-slate-900' }
  end
end

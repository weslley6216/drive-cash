class StatCardComponent < ApplicationComponent
  SIZES = {
    default: 'text-xl lg:text-2xl',
    sm:      'text-sm lg:text-xl'
  }.freeze

  COLORS = {
    green:  {
      bg:       'bg-green-50',
      border:   'border-green-200',
      title:    'text-green-700',
      value:    'text-green-900',
      subtitle: 'text-green-600'
    },
    red:    {
      bg:       'bg-red-50',
      border:   'border-red-200',
      title:    'text-red-700',
      value:    'text-red-900',
      subtitle: 'text-red-600'
    },
    blue:   {
      bg:       'bg-blue-50',
      border:   'border-blue-200',
      title:    'text-blue-700',
      value:    'text-blue-900',
      subtitle: 'text-blue-600'
    },
    yellow: {
      bg:       'bg-yellow-50',
      border:   'border-yellow-200',
      title:    'text-yellow-700',
      value:    'text-yellow-900',
      subtitle: 'text-yellow-600'
    },
    purple: {
      bg:       'bg-purple-50',
      border:   'border-purple-200',
      title:    'text-purple-700',
      value:    'text-purple-900',
      subtitle: 'text-purple-600'
    }
  }.freeze

  def initialize(title:, value:, subtitle: nil, color:, icon:, href: nil, size: :default)
    @title = title
    @value = value
    @subtitle = subtitle
    @color = color
    @icon = icon
    @href = href
    @size = size
  end

  def view_template
    container_tag(class: card_classes) do
      div(class: 'flex items-start justify-between gap-2') do
        p(class: title_classes) { @title }
        icon_section
      end
      p(class: value_classes) { @value }
      p(class: subtitle_classes) { @subtitle } if @subtitle
    end
  end

  private

  def icon_section
    return unless @icon

    render @icon.new(class: 'w-5 h-5 lg:w-6 lg:h-6 opacity-50')
  end

  def container_tag(**attributes, &block)
    if @href.present?
      a(**attributes, href: @href, data: { turbo_frame: 'modal' }, class: class_names(attributes[:class], 'block cursor-pointer transition-opacity hover:opacity-90'), &block)
    else
      div(**attributes, &block)
    end
  end

  def card_classes
    class_names('border-2 rounded-xl p-3 shadow-sm', colors[:bg], colors[:border])
  end

  def title_classes
    class_names('text-sm font-medium opacity-75', colors[:title])
  end

  def value_classes
    class_names("#{SIZES.fetch(@size, SIZES[:default])} font-bold mt-1 whitespace-nowrap", colors[:value])
  end

  def subtitle_classes
    class_names('text-xs mt-1 opacity-60 whitespace-nowrap', colors[:subtitle])
  end

  def colors
    @colors ||= COLORS.fetch(@color, default_colors)
  end

  def default_colors
    {
      bg:       'bg-white',
      border:   'border-slate-200',
      title:    'text-slate-600',
      value:    'text-slate-900',
      subtitle: 'text-slate-500'
    }
  end
end

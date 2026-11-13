class StatCardComponent < ApplicationComponent
  SIZES = {
    default: 'text-xl lg:text-2xl',
    sm:      'text-sm lg:text-xl'
  }.freeze

  COLORS = {
    green:  {
      bg:       'bg-emerald-50',
      border:   'border-emerald-200',
      title:    'text-emerald-700',
      value:    'text-emerald-900',
      subtitle: 'text-emerald-600'
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

  def initialize(title:, value:, color:, icon:, subtitle: nil, short_title: nil, href: nil, size: :default)
    @title = title
    @short_title = short_title
    @value = value
    @subtitle = subtitle
    @color = color
    @icon = icon
    @href = href
    @size = size
  end

  def view_template
    container_tag(class: card_classes) do
      div(class: 'grid grid-cols-[minmax(0,1fr)_auto] items-start gap-x-2 lg:gap-x-3') do
        p(class: title_classes) { title_content }
        icon_section
        p(class: value_classes) { @value }
        p(class: subtitle_classes) { @subtitle } if @subtitle
      end
    end
  end

  private

  def title_content
    return plain(@title) unless @short_title

    span(class: 'lg:hidden') { @short_title }
    span(class: 'hidden lg:inline') { @title }
  end

  def icon_section
    return unless @icon

    div(class: class_names('row-start-1 col-start-2 lg:row-span-3 flex-shrink-0 lg:w-9 lg:h-9 lg:rounded-lg flex items-center justify-center', colors[:title])) do
      render @icon.new(class: 'w-5 h-5 opacity-50')
    end
  end

  def container_tag(**attributes, &block)
    if @href.present?
      a(**attributes, href: @href, data: { turbo_frame: 'modal' }, class: class_names(attributes[:class], 'block cursor-pointer transition-opacity hover:opacity-90'), &block)
    else
      div(**attributes, &block)
    end
  end

  def card_classes
    class_names('border-2 rounded-xl p-3 shadow-sm lg:p-4 lg:shadow-none', colors[:bg], colors[:border])
  end

  def title_classes
    class_names('text-sm font-medium opacity-75 lg:text-xs lg:font-semibold lg:uppercase lg:tracking-wide lg:opacity-80', colors[:title])
  end

  def value_classes
    class_names("#{SIZES.fetch(@size, SIZES[:default])} font-bold mt-1 lg:mt-1.5 lg:tabular-nums lg:tracking-tight -mx-1 lg:mx-0 truncate col-span-2 lg:col-span-1", colors[:value])
  end

  def subtitle_classes
    class_names('text-xs mt-1 opacity-60 lg:opacity-70 truncate col-span-2 lg:col-span-1', colors[:subtitle])
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

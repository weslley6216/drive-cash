# frozen_string_literal: true

class StatCardComponent < ApplicationComponent
  COLORS = {
    green: {
      bg: 'bg-green-50',
      border: 'border-green-200',
      title: 'text-green-700',
      value: 'text-green-900',
      subtitle: 'text-green-600'
    },
    red: {
      bg: 'bg-red-50',
      border: 'border-red-200',
      title: 'text-red-700',
      value: 'text-red-900',
      subtitle: 'text-red-600'
    },
    blue: {
      bg: 'bg-blue-50',
      border: 'border-blue-200',
      title: 'text-blue-700',
      value: 'text-blue-900',
      subtitle: 'text-blue-600'
    },
    yellow: {
      bg: 'bg-yellow-50',
      border: 'border-yellow-200',
      title: 'text-yellow-700',
      value: 'text-yellow-900',
      subtitle: 'text-yellow-600'
    }
  }.freeze

  def initialize(title:, value:, subtitle: nil, color:, icon:)
    @title = title
    @value = value
    @subtitle = subtitle
    @color = color
    @icon = icon
  end

  def view_template
    div(class: card_classes) do
      div(class: 'flex items-start justify-between') do
        content_section
        icon_section
      end
    end
  end

  private

  def content_section
    div(class: 'flex-1') do
      p(class: title_classes) { @title }
      p(class: value_classes) { @value }
      p(class: subtitle_classes) { @subtitle } if @subtitle
    end
  end

  def icon_section
    render @icon.new(class: 'w-8 h-8 opacity-50')
  end

  def card_classes
    class_names('border-2 rounded-lg p-4 shadow-sm', colors[:bg], colors[:border])
  end

  def title_classes
    class_names('text-sm font-medium opacity-75', colors[:title])
  end

  def value_classes
    class_names('text-2xl font-bold mt-1', colors[:value])
  end

  def subtitle_classes
    class_names('text-xs mt-1 opacity-60', colors[:subtitle])
  end

  def colors
    @colors ||= COLORS.fetch(@color, default_colors)
  end

  def default_colors
    {
      bg: 'bg-white',
      border: 'border-slate-200',
      title: 'text-slate-600',
      value: 'text-slate-900',
      subtitle: 'text-slate-500'
    }
  end
end

class ButtonComponent < ApplicationComponent
  def initialize(variant: :primary, size: :medium, **attributes)
    @variant = variant
    @size = size
    @attributes = attributes
  end

  def view_template(&block)
    button(**merged_attributes, &block)
  end

  private

  def merged_attributes
    {
      class: class_names(
        base_classes,
        variant_classes,
        size_classes,
        @attributes[:class]
      )
    }.merge(@attributes.except(:class))
  end

def base_classes
  <<~HTML.squish
    inline-flex items-center justify-center font-medium transition-colors#{' '}
    rounded-lg focus:outline-none focus:ring-2 focus:ring-offset-2#{' '}
    disabled:opacity-50 disabled:cursor-not-allowed
  HTML
end

  def variant_classes
    case @variant
    when :primary
      'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500'
    when :secondary
      'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500'
    when :danger
      'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500'
    when :success
      'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500'
    else
      'bg-gray-100 text-gray-900 hover:bg-gray-200'
    end
  end

  def size_classes
    case @size
    when :small then 'px-3 py-1.5 text-sm'
    when :medium then 'px-4 py-2 text-base'
    when :large then 'px-6 py-3 text-lg'
    else 'px-4 py-2'
    end
  end
end

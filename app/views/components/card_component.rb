# frozen_string_literal: true

class CardComponent < ApplicationComponent
  def initialize(padding: true, shadow: true, **attributes)
    @padding = padding
    @shadow = shadow
    @attributes = attributes
  end

  def view_template(&block)
    div(**merged_attributes, &block)
  end

  private

  def merged_attributes
    {
      class: class_names(
        "bg-white rounded-lg",
        @padding ? "p-6" : nil,
        shadow_class,
        @attributes[:class]
      )
    }.merge(@attributes.except(:class))
  end

  def shadow_class
    return nil unless @shadow

    case @shadow
    when true
      "shadow-md"
    when :sm
      "shadow-sm"
    when :md
      "shadow-md"
    when :lg
      "shadow-lg"
    when :xl
      "shadow-xl"
    else
      nil
    end
  end
end

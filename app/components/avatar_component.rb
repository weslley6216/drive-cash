class AvatarComponent < ApplicationComponent
  def initialize(name:, size_classes:)
    @name = name
    @size_classes = size_classes
  end

  def view_template
    div(class: "#{@size_classes} rounded-full bg-blue-600 text-white flex items-center justify-center font-bold") do
      plain initial
    end
  end

  private

  def initial = @name.to_s.strip[0]&.upcase || '?'
end

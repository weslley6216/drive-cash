# frozen_string_literal: true

class IconComponent < ApplicationComponent
  ICONS = {
    dollar_sign: ->(svg) {
      svg.path(
        d: 'M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6',
        stroke: 'currentColor',
        stroke_width: '2',
        stroke_linecap: 'round',
        stroke_linejoin: 'round',
        fill: 'none'
      )
    },
    alert_triangle: ->(svg) {
      svg.path(
        d: 'm21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z',
        stroke: 'currentColor',
        stroke_width: '2',
        stroke_linecap: 'round',
        stroke_linejoin: 'round',
        fill: 'none'
      )
      svg.path(d: 'M12 9v4', stroke: 'currentColor', stroke_width: '2', stroke_linecap: 'round', stroke_linejoin: 'round')
      svg.path(d: 'M12 17h.01', stroke: 'currentColor', stroke_width: '2', stroke_linecap: 'round', stroke_linejoin: 'round')
    },
    trending_up: ->(svg) {
      svg.polyline(
        points: '22 7 13.5 15.5 8.5 10.5 2 17',
        stroke: 'currentColor',
        stroke_width: '2',
        stroke_linecap: 'round',
        stroke_linejoin: 'round',
        fill: 'none'
      )
      svg.polyline(
        points: '16 7 22 7 22 13',
        stroke: 'currentColor',
        stroke_width: '2',
        stroke_linecap: 'round',
        stroke_linejoin: 'round',
        fill: 'none'
      )
    },
    calendar: ->(svg) {
      svg.rect(x: '3', y: '4', width: '18', height: '18', rx: '2', ry: '2', stroke: 'currentColor', stroke_width: '2', fill: 'none')
      svg.path(d: 'M16 2v4', stroke: 'currentColor', stroke_width: '2', stroke_linecap: 'round')
      svg.path(d: 'M8 2v4', stroke: 'currentColor', stroke_width: '2', stroke_linecap: 'round')
      svg.path(d: 'M3 10h18', stroke: 'currentColor', stroke_width: '2', stroke_linecap: 'round')
    },
    plus: ->(svg) {
      svg.path(
        d: 'M12 5v14M5 12h14',
        stroke: 'currentColor',
        stroke_width: '2',
        stroke_linecap: 'round',
        stroke_linejoin: 'round'
      )
    },
    x: ->(svg) {
      svg.path(d: 'M18 6L6 18M6 6l12 12', stroke: 'currentColor', stroke_width: '2', stroke_linecap: 'round', stroke_linejoin: 'round')
    },
    save: ->(svg) {
      svg.path(d: 'M15.2 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V8.8L15.2 3z',
               stroke: 'currentColor', fill: 'none', stroke_width: '2',
               stroke_linecap: 'round', stroke_linejoin: 'round')
      svg.path(d: 'M7 21V13h10v8', stroke: 'currentColor', fill: 'none',
               stroke_width: '2', stroke_linecap: 'round', stroke_linejoin: 'round')
      svg.path(d: 'M7 3v5h8', stroke: 'currentColor', fill: 'none',
               stroke_width: '2', stroke_linecap: 'round', stroke_linejoin: 'round')
    }
  }.freeze

  def initialize(name:, **attributes)
    @name = name
    @attributes = attributes
  end

  def view_template
    svg(**svg_attributes) { |s| ICONS[@name]&.call(s) }
  end

  private

  def svg_attributes
    {
      xmlns: 'http://www.w3.org/2000/svg',
      width: '24',
      height: '24',
      viewBox: '0 0 24 24',
      class: class_names('opacity-50', @attributes[:class])
    }.merge(@attributes.except(:class))
  end
end

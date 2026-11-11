module Notifications
  class IconTileComponent < ApplicationComponent
    PALETTES = {
      danger:  'bg-red-50 text-red-600',
      warning: 'bg-amber-50 text-amber-500',
      success: 'bg-emerald-50 text-emerald-500',
      info:    'bg-blue-50 text-blue-600',
      neutral: 'bg-slate-100 text-slate-500'
    }.freeze

    def initialize(icon:, palette_key:, dimmed: false)
      @icon = icon
      @palette_key = palette_key
      @dimmed = dimmed
    end

    def view_template
      div(class: tile_classes) { render @icon.new(class: 'w-[17px] h-[17px]') }
    end

    private

    def tile_classes
      class_names(
        'w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0',
        palette_classes,
        ('opacity-50' if @dimmed)
      )
    end

    def palette_classes
      PALETTES.fetch(@palette_key, PALETTES[:neutral])
    end
  end
end

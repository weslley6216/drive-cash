module History
  class EntryIconComponent < ApplicationComponent
    include PlatformPalette
    include CategoryPalette

    BADGE_LETTERS = 4
    SIZES = {
      list:  { tile: 'w-10 h-10 rounded-lg text-[10px]', icon: 'w-[18px] h-[18px]' },
      table: { tile: 'w-7 h-7 rounded-md text-[9px]', icon: 'w-[13px] h-[13px]' }
    }.freeze

    def initialize(row:, size: :list)
      @row = row
      @size = SIZES.fetch(size)
    end

    def view_template
      @row.platform ? platform_badge : category_tile
    end

    private

    def platform_badge
      div(class: "#{@size[:tile]} flex items-center justify-center flex-shrink-0 font-bold",
          style: "background-color: #{platform_color(@row.platform)}; color: #{platform_fg(@row.platform)}") do
        @row.label_text.first(BADGE_LETTERS)
      end
    end

    def category_tile
      div(class: "#{@size[:tile]} bg-red-50 text-red-600 flex items-center justify-center flex-shrink-0") do
        render category_icon(@row.category).new(class: @size[:icon])
      end
    end
  end
end

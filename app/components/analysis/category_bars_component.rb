module Analysis
  class CategoryBarsComponent < ApplicationComponent
    include CardStyles
    include CategoryPalette

    def initialize(categories:, month: nil)
      @categories = categories
      @month = month
      @total = categories.sum { |row| row[:amount].to_f }
    end

    def view_template
      section(class: "#{CARD} p-4 #{DESKTOP_FLAT} lg:p-6 lg:h-full") do
        h3(class: 'text-sm lg:text-base font-semibold text-slate-800 mb-1') { I18n.t('analysis.show_view.categories.title') }
        p(class: 'text-xs text-slate-500 mb-3 lg:mb-5') { total_subtitle }
        @categories.empty? ? empty_state : list
      end
    end

    private

    def total_subtitle
      key = @month ? 'analysis.show_view.categories.total_monthly' : 'analysis.show_view.categories.total_annual'
      I18n.t(key, value: format_currency(@total))
    end

    MOBILE_ROWS = 4

    def list
      div(class: 'flex flex-col gap-3') do
        @categories.each_with_index { |row, index| category_row(row, desktop_only: index >= MOBILE_ROWS) }
      end
    end

    def category_row(row, desktop_only:)
      color = category_color(row[:id])
      div(data: { category_row: row[:id] }, class: desktop_only ? 'hidden lg:block' : nil) do
        div(class: 'flex items-center justify-between mb-1') do
          div(class: 'flex items-center gap-2.5 min-w-0') do
            div(class: 'hidden lg:flex w-7 h-7 rounded-lg items-center justify-center flex-shrink-0',
                style: "background: #{color}20; color: #{color}") do
              render category_icon(row[:id]).new(class: 'w-3.5 h-3.5')
            end
            span(class: 'text-sm text-slate-700 truncate') { row[:label] }
          end
          div(class: 'flex items-center gap-4 text-sm whitespace-nowrap') do
            span(class: 'hidden lg:inline text-slate-400 w-12 text-right tabular-nums') { "#{format_percentage(row[:percent])}%" }
            span(class: 'font-semibold text-slate-800 lg:text-slate-900 lg:tabular-nums lg:w-24 lg:text-right') { format_currency(row[:amount]) }
          end
        end
        div(class: 'h-1.5 bg-slate-100 rounded-full overflow-hidden') do
          div(class: 'h-full rounded-full', style: "width: #{row[:percent]}%; background-color: #{color}")
        end
      end
    end

    def empty_state
      p(class: 'text-sm text-slate-400 text-center py-6') { I18n.t('analysis.show_view.categories.empty') }
    end
  end
end

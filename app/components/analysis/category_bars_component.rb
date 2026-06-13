module Analysis
  class CategoryBarsComponent < ApplicationComponent
    include CategoryPalette

    def initialize(categories:, month: nil)
      @categories = categories
      @month = month
      @total = categories.sum { |row| row[:amount].to_f }
    end

    def view_template
      section(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        h3(class: 'text-sm font-semibold text-slate-800 mb-1') { I18n.t('analysis.show_view.categories.title') }
        p(class: 'text-xs text-slate-500 mb-3') { total_subtitle }
        @categories.empty? ? empty_state : list
      end
    end

    private

    def total_subtitle
      key = @month ? 'analysis.show_view.categories.total_monthly' : 'analysis.show_view.categories.total_annual'
      I18n.t(key, value: format_currency(@total))
    end

    def list
      div(class: 'space-y-3') do
        @categories.each { |row| category_row(row) }
      end
    end

    def category_row(row)
      color = category_color(row[:id])
      div(data: { category_row: row[:id] }) do
        div(class: 'flex items-center justify-between mb-1') do
          div(class: 'flex items-center gap-2 min-w-0') do
            div(class: 'w-6 h-6 rounded flex items-center justify-center',
                style: "background: #{color}20; color: #{color}") do
              render category_icon(row[:id]).new(class: 'w-[13px] h-[13px]')
            end
            span(class: 'text-sm text-slate-700') { row[:label] }
          end
          div(class: 'flex items-center gap-2 whitespace-nowrap') do
            span(class: 'text-xs text-slate-500') { "#{row[:percent]}%" }
            span(class: 'text-sm font-semibold text-slate-800') { format_currency(row[:amount]) }
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

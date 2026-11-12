class CategoryBreakdownComponent < ApplicationComponent
  include CategoryPalette

  def initialize(categories:)
    @categories = categories
  end

  MOBILE_ROWS = 4
  DESKTOP_ROWS = 5

  def view_template
    section(class: 'animate-slide-up') do
      header
      @categories.empty? ? empty_state : list
    end
  end

  private

  def header
    div(class: 'flex items-center justify-between mb-2 px-1 lg:mb-3 lg:px-0') do
      h2(class: 'text-sm font-semibold text-slate-700 lg:text-base lg:text-slate-800') { I18n.t('category_breakdown_component.title') }
      a(href: helpers.analysis_path, class: 'text-xs font-medium text-blue-600 lg:text-sm lg:hover:underline') do
        I18n.t('category_breakdown_component.see_analysis')
      end
    end
  end

  def empty_state
    p(class: 'text-sm text-slate-500 bg-white border border-slate-200 rounded-lg px-4 py-6 text-center') do
      I18n.t('category_breakdown_component.empty')
    end
  end

  def list
    div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4 space-y-3 lg:border-slate-200 lg:shadow-none lg:p-5 lg:space-y-3.5') do
      @categories.first(DESKTOP_ROWS).each_with_index do |category, index|
        category_row(category, desktop_only: index >= MOBILE_ROWS)
      end
    end
  end

  def category_row(category, desktop_only:)
    color = category_color(category[:id])
    div(data: { category_row: category[:id] }, class: desktop_only ? 'hidden lg:block' : nil) do
      div(class: 'flex items-center justify-between mb-1 lg:mb-1.5') do
        div(class: 'flex items-center gap-2 lg:gap-2.5 min-w-0') do
          div(class: 'w-6 h-6 rounded lg:w-7 lg:h-7 lg:rounded-lg flex items-center justify-center flex-shrink-0', style: "background: #{color}20; color: #{color}") do
            render category_icon(category[:id]).new(class: 'w-[13px] h-[13px] lg:w-3.5 lg:h-3.5')
          end
          span(class: 'text-sm text-slate-700 truncate') { category[:label] }
        end
        div(class: 'flex items-center gap-3 text-sm') do
          span(class: 'hidden lg:inline text-slate-400') do
            I18n.t('category_breakdown_component.percent', value: format_percentage(category[:percent]))
          end
          span(class: 'font-medium text-slate-800 lg:text-slate-900 whitespace-nowrap lg:w-20 lg:text-right') { format_currency(category[:amount]) }
        end
      end
      div(class: 'h-1.5 bg-slate-100 rounded-full overflow-hidden') do
        div(class: 'h-full rounded-full', style: "width: #{category[:percent]}%; background-color: #{color}")
      end
    end
  end
end

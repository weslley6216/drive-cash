class CategoryBreakdownComponent < ApplicationComponent
  include CategoryPalette

  def initialize(categories:)
    @categories = categories
  end

  def view_template
    section(class: 'mt-6 animate-slide-up') do
      header
      @categories.empty? ? empty_state : list
    end
  end

  private

  def header
    div(class: 'flex items-center justify-between mb-3') do
      h2(class: 'text-base font-semibold text-slate-800') { I18n.t('category_breakdown_component.title') }
    end
  end

  def empty_state
    p(class: 'text-sm text-slate-500 bg-white border border-slate-200 rounded-lg px-4 py-6 text-center') do
      I18n.t('category_breakdown_component.empty')
    end
  end

  def list
    div(class: 'bg-white border border-slate-200 rounded-lg p-4 space-y-3') do
      @categories.each { |category| category_row(category) }
    end
  end

  def category_row(category)
    div(class: 'space-y-1', data: { category_row: category[:id] }) do
      div(class: 'flex items-center justify-between text-sm') do
        div(class: 'flex items-center gap-2') do
          render category_icon(category[:id]).new(class: 'w-4 h-4', style: "color: #{category_color(category[:id])}")
          span(class: 'font-medium text-slate-700') { category[:label] }
        end
        div(class: 'flex items-center gap-2 text-xs text-slate-500') do
          span { format_currency(category[:amount]) }
          span(class: 'font-semibold text-slate-700') do
            I18n.t('category_breakdown_component.percent', value: category[:percent].to_s)
          end
        end
      end
      div(class: 'h-2 rounded-full bg-slate-100 overflow-hidden') do
        div(class: 'h-full rounded-full', style: "width: #{category[:percent]}%; background-color: #{category_color(category[:id])}")
      end
    end
  end
end

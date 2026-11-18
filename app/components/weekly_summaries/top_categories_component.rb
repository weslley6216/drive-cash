module WeeklySummaries
  class TopCategoriesComponent < ApplicationComponent
    include CategoryPalette

    def initialize(categories:, total:)
      @categories = categories
      @total = total
    end

    def render? = @categories.any?

    def view_template
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        header_row
        div(class: 'space-y-2.5') { @categories.each { |category| category_row(category) } }
      end
    end

    private

    def header_row
      div(class: 'flex items-baseline justify-between mb-3') do
        h3(class: 'text-sm font-semibold text-slate-800') { t('weekly_summaries.show.top_categories.title') }
        span(class: 'text-xs text-slate-400 tabular-nums') { format_currency(@total) }
      end
    end

    def category_row(category)
      div do
        div(class: 'flex items-center justify-between text-sm') do
          span(class: 'flex items-center gap-2 text-slate-700') do
            span(class: 'w-6 h-6 rounded flex items-center justify-center bg-red-50 text-red-600') do
              render category_icon(category.key).new(class: 'w-[13px] h-[13px]')
            end
            plain I18n.t("activerecord.attributes.expense.categories.#{category.key}")
          end
          span(class: 'font-semibold text-slate-800 tabular-nums') { format_currency(category.amount) }
        end
        div(class: 'h-1.5 bg-slate-100 rounded-full overflow-hidden mt-1.5 ml-8') do
          div(class: 'h-full bg-red-400 rounded-full', style: "width: #{bar_width(category)}%")
        end
      end
    end

    def bar_width(category)
      (category.amount.to_f / max_amount * 100).round(1)
    end

    def max_amount
      @categories.first.amount
    end
  end
end

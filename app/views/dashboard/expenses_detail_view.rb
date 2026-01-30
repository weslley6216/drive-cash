module Dashboard
  class ExpensesDetailView < ApplicationView
    def initialize(expenses:, total:, filters:, expenses_by_month: nil, annual: false)
      @expenses = expenses
      @expenses_by_month = expenses_by_month
      @total = total
      @annual = annual
      @filters = filters
      @theme = :red
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(
          class: modal_backdrop_classes,
          data_controller: 'modal',
          data_action: 'mousedown->modal#handleBackgroundClick'
        ) do
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)} max-w-lg") do
            render_header(subtitle: period_subtitle)
            list_section
            close_action
          end
        end
      end
    end

    private

    def period_subtitle
      if @filters[:month].present?
        I18n.l(Date.new(@filters[:year], @filters[:month], 1), format: :month_and_year)
      else
        @filters[:year].to_s
      end
    end

    def list_section
      div(class: 'p-4 sm:p-6 pt-4') do
        if @annual ? @expenses_by_month&.any? : @expenses.any?
          expense_list
          total_bar
        else
          p(class: 'text-slate-500 text-center py-8') { t('.empty') }
        end
      end
    end

    def expense_list
      div(class: 'space-y-4') do
        if @annual
          @expenses_by_month.each do |row|
            div(class: 'flex justify-between items-center py-3 border-b border-slate-100') do
              span(class: 'text-slate-800 capitalize') { row[:month_name].to_s }
              span(class: 'font-medium text-red-700') { format_currency(row[:total]) }
            end
          end
        else
          expenses_grouped_by_date.each do |date, list|
            div(class: 'space-y-1') do
              p(class: 'text-xs font-medium text-slate-500 uppercase tracking-wide pt-2 first:pt-0') { format_date(date) }
              list.each do |expense|
                div(class: 'flex justify-between items-start gap-3 py-2 pl-3 border-l-2 border-slate-200') do
                  div(class: 'min-w-0 flex-1') do
                    p(class: 'text-slate-800 font-medium break-words') { expense.vendor.presence || '—' }
                    p(class: 'text-sm text-slate-500') { category_label(expense) }
                  end
                  span(class: 'font-medium text-red-700 flex-shrink-0') { format_currency(expense.amount) }
                end
              end
            end
          end
        end
      end
    end

    def total_bar
      div(class: 'flex justify-between items-center py-3 mt-3 pt-3 border-t-2 border-slate-200 font-bold bg-slate-50 -mx-4 px-4 sm:-mx-6 sm:px-6 rounded-b-lg') do
        span(class: 'text-slate-800') { t('.total') }
        span(class: 'text-red-800') { format_currency(@total) }
      end
    end

    def expenses_grouped_by_date
      @expenses_grouped_by_date ||= @expenses.to_a.group_by(&:date).sort_by { |date, _| date }
    end

    def format_date(date)
      I18n.l(date, format: :short)
    end

    def category_label(expense)
      Expense.human_enum_name(:category, expense.category)
    end

    def close_action
      div(class: 'p-6 pt-0 flex justify-end') do
        button(
          type: 'button',
          data_action: 'modal#close',
          class: 'px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-50 transition-colors',
          aria_label: t('.close')
        ) { t('.close') }
      end
    end
  end
end

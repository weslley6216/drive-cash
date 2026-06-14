module Dashboard
  class ExpensesDetailView < DetailModalView
    def initialize(expenses:, total:, filters:, expenses_by_month: nil, annual: false)
      @expenses = expenses
      @expenses_by_month = expenses_by_month
      @total = total
      @annual = annual
      @filters = filters
      @theme = :red
    end

    def view_template
      render_detail_modal(theme: @theme) do
        render_header(subtitle: period_subtitle(@filters))
        scrollable_content
        fixed_footer
      end
    end

    private

    def scrollable_content
      div(class: 'flex-1 overflow-y-auto p-4 sm:p-6 pt-4') do
        if @annual ? @expenses_by_month&.any? : @expenses.any?
          expense_list
        else
          p(class: 'text-slate-500 text-center py-8') { t('.empty') }
        end
      end
    end

    def fixed_footer
      render_detail_footer(
        annual: @annual,
        show_total: @annual ? @expenses_by_month&.any? : @expenses.any?,
        total: @total,
        total_class: 'text-red-800',
        back_path: dashboard_expenses_detail_path(year: @filters[:year]),
        labels: {
          total: t('.total'),
          close: t('.close'),
          back: t('.back')
        },
        padding_classes: 'px-4 sm:px-6'
      )
    end

    def expense_list
      div(class: 'space-y-4 pb-4') do
        if @annual
          @expenses_by_month.each do |row|
            link_to(
              dashboard_expenses_detail_path(year: @filters[:year], month: row[:month]),
              data: { turbo_frame: 'modal' },
              class: 'flex justify-between items-center py-3 border-b border-slate-100 text-slate-800 capitalize hover:bg-slate-50 transition-colors active:bg-slate-100 rounded'
            ) do
              span { row[:month_name].to_s }
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
                    p(class: 'text-slate-800 font-medium break-words') { expense.description || '—' }
                    if expense.installment?
                      p(class: 'text-xs text-slate-500 mt-0.5') { t('.installment_of', current: expense.installment_number, total: expense.installment_count) }
                    end
                    p(class: 'text-sm text-slate-500') { expense.vendor.presence || '—' }
                  end
                  div(class: 'flex items-center gap-2 flex-shrink-0 group') do
                    span(class: 'font-medium text-red-700') { format_currency(expense.amount) }
                    render_record_actions(
                      edit_path: edit_expense_path(expense, context: { year: @filters[:year], month: @filters[:month] }),
                      delete_path: expense_path(expense, context: @filters),
                      edit_hover: 'hover:text-red-600',
                      labels: { edit: t('.edit'), delete: t('.delete'), confirm: t('.confirm_delete') }
                    )
                  end
                end
              end
            end
          end
        end
      end
    end

    def expenses_grouped_by_date
      @expenses_grouped_by_date ||= @expenses.to_a.group_by(&:date)
    end
  end
end

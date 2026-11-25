module Records
  class NewView < ApplicationView
    include RecordFormData

    INSTALLMENT_INPUT = 'w-full px-4 py-2 rounded-lg border focus:outline-none focus:ring-2 transition-all border-slate-300 ' \
                        'text-slate-900 focus:ring-red-500 focus:border-red-500 bg-white'.freeze

    def initialize(type:, tank:, earning: nil, expense: nil, context: nil, active_vendor: nil)
      @type = type.to_s
      @earning = earning || Earning.new(date: Date.current)
      @expense = expense || Expense.new(date: Date.current)
      @context = context || {}
      @active_vendor = active_vendor.to_s
      @tank = tank
    end

    def view_template
      render LayoutComponent.new(title: t('records.new_view.title')) do
        div(class: 'h-full flex flex-col bg-white safe-top sm:pt-0 max-w-[640px] mx-auto w-full lg:max-w-none lg:bg-black/30 lg:items-center lg:justify-center lg:p-8') do
          div(class: 'group/record h-full flex flex-col w-full min-h-0 lg:h-auto lg:max-h-full lg:max-w-2xl lg:bg-white lg:rounded-2xl ' \
                     'lg:shadow-2xl lg:border lg:border-slate-200 lg:overflow-hidden',
              data:  record_form_data(type: @type, selected_category: @expense.category.to_s, active_vendor: @active_vendor,
                                      tank_balance: tank_balance)) do
            form_with(url: records_path, method: :post, scope: :record, html: { class: 'h-full flex flex-col min-h-0' }) do
              input(type: 'hidden', name: 'context[year]', value: @context[:year])
              input(type: 'hidden', name: 'context[month]', value: @context[:month])

              top_bar
              desktop_header
              type_toggle_section
              scrollable_body
              render Records::StickyActionBarComponent.new(theme: cta_theme) { cancel_link }
            end
          end
        end
      end
    end

    private

    def earning? = @type == 'earning'
    def expense? = @type == 'expense'

    def cta_theme
      earning? ? :emerald : :red
    end

    def cancel_link
      link_to(t('records.new_view.cancel'), root_path, class: 'hidden lg:inline px-4 py-2 text-sm font-medium text-slate-600 hover:text-slate-900')
    end

    def top_bar
      div(class: 'px-5 pt-2 pb-3 flex items-center justify-between lg:hidden') do
        link_to(root_path, class: 'p-1 -ml-1 text-slate-500', aria: { label: t('records.new_view.close') }) do
          render PhlexIcons::Lucide::X.new(class: 'w-6 h-6')
        end
        p(class: 'text-sm font-semibold text-slate-700') { t('records.new_view.title') }
        button(
          type:  'submit',
          class: 'text-sm font-semibold text-blue-600 cursor-pointer'
        ) { t('records.new_view.save') }
      end
    end

    def desktop_header
      div(class: 'hidden lg:flex items-center justify-between px-6 py-4 border-b border-slate-100') do
        h2(class: 'text-lg font-bold text-slate-900') { t('records.new_view.title') }
        link_to(root_path, class: 'text-slate-400 hover:text-slate-700', aria: { label: t('records.new_view.close') }) do
          render PhlexIcons::Lucide::X.new(class: 'w-5 h-5')
        end
      end
    end

    def type_toggle_section
      div(class: 'px-5 pb-3 lg:px-6 lg:pt-6 lg:pb-0') do
        render Records::EntryTypeToggleComponent.new(active: @type)
      end
    end

    def scrollable_body
      div(class: 'flex-1 min-h-0 overflow-y-auto px-5 pb-6 space-y-5 lg:px-6 lg:pt-5') do
        render Records::AmountAndDateComponent.new(amount: shared_amount, date: shared_date, theme: cta_theme)
        earning_block
        expense_block
        render Records::ErrorsComponent.new(record: earning? ? @earning : @expense)
      end
    end

    def shared_amount
      (earning? ? @earning.amount : @expense.amount)
    end

    def shared_date
      (earning? ? @earning.date : @expense.date) || Date.current
    end

    def earning_block
      div(class: (earning? ? '' : 'hidden'), data: { record_form_target: 'earningFields' }) do
        render Records::EarningFieldsComponent.new(earning: @earning)
      end
    end

    def expense_block
      div(class: (expense? ? '' : 'hidden'), data: { record_form_target: 'expenseFields' }) do
        render Records::ExpenseFieldsComponent.new(expense: @expense, tank_balance: tank_balance) { installment_section }
      end
    end

    def tank_balance = (@tank[:balance] if @tank[:active])

    def installment_section
      div(
        class: 'rounded-xl border border-slate-200 bg-slate-50 px-4 py-3',
        data:  { controller: 'expense-installment', action: 'change->expense-installment#toggle' }
      ) do
        label(for: 'installment_repeat', class: 'flex items-center justify-between gap-3 cursor-pointer') do
          div do
            p(class: 'text-sm font-semibold text-slate-800') { t('records.new_view.recurring_toggle.title') }
            p(class: 'text-xs text-slate-500') { t('records.new_view.recurring_toggle.subtitle') }
          end
          span(class: 'relative inline-flex flex-shrink-0 items-center') do
            raw helpers.check_box_tag('installment[repeat]', '1', false, id: 'installment_repeat', class: 'peer sr-only')
            span(class: 'h-6 w-11 rounded-full bg-slate-300 transition-colors peer-checked:bg-red-500')
            span(class: 'pointer-events-none absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5')
          end
        end
        div(class: 'hidden mt-3 pt-3 space-y-3 border-t border-slate-200', data: { expense_installment_target: 'fields' }) do
          div do
            label(for: 'installment_period', class: 'block text-sm font-medium mb-2 text-slate-700') { t('records.new_view.installment.period_label') }
            raw helpers.select_tag('installment[period]', helpers.options_for_select(installment_periods, 'monthly'), class: INSTALLMENT_INPUT)
          end
          div do
            label(for: 'installment_repetitions', class: 'block text-sm font-medium mb-2 text-slate-700') { t('records.new_view.installment.repetitions_label') }
            raw helpers.number_field_tag('installment[repetitions]', 3, min: 2, step: 1, class: INSTALLMENT_INPUT)
          end
          p(class: 'text-xs text-slate-500') { t('records.new_view.installment.repeat_hint') }
        end
      end
    end

    def installment_periods
      Expense::INSTALLMENT_PERIODS.map { |period| [t("records.new_view.installment.periods.#{period}"), period] }
    end
  end
end

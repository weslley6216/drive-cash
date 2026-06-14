module Expenses
  class NewView < FormView
    def initialize(expense:, context: {}, totals: nil)
      super(expense: expense, context: context)
    end

    private

    def form_body(_form)
      installment_section
    end

    def installment_section
      div(
        class: 'rounded-lg border border-slate-200 bg-slate-50/80 p-4 space-y-3',
        data: { controller: 'expense-installment', action: 'change->expense-installment#toggle' }
      ) do
        div(class: 'flex items-start gap-3') do
          raw helpers.check_box_tag('installment[repeat]', '1', false, id: 'installment_repeat', class: 'mt-1 rounded border-slate-300 text-red-600 focus:ring-red-500')
          label(for: 'installment_repeat', class: 'text-sm text-slate-700 cursor-pointer leading-relaxed') { t('.labels.repeat') }
        end
        div(class: 'hidden space-y-3 pl-7 border-l-2 border-slate-200 ml-2', data: { expense_installment_target: 'fields' }) do
          field_wrapper(t('.labels.period'), theme: @theme) do
            options = Expense::INSTALLMENT_PERIODS.map { |p| [t(".periods.#{p}"), p] }
            raw helpers.select_tag(
              'installment[period]',
              helpers.options_for_select(options, 'monthly'),
              class: "#{input_classes(theme: @theme)} bg-white"
            )
          end
          field_wrapper(t('.labels.repetitions'), theme: @theme) do
            raw helpers.number_field_tag(
              'installment[repetitions]',
              3,
              min: 2,
              step: 1,
              class: input_classes(theme: @theme)
            )
          end
          p(class: 'text-xs text-slate-500') { t('.repeat_hint') }
        end
      end
    end
  end
end

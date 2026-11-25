module Records
  class TankDebitCardComponent < ApplicationComponent
    def initialize(balance:, expense:)
      @balance = balance
      @expense = expense
    end

    def view_template
      div(class: class_names('rounded-xl bg-slate-50 border border-slate-200 p-3.5 flex items-center gap-3',
                             ('hidden' unless @expense.category_fuel?)),
          data:  { record_form_target: 'tankDebit' }) do
        div(class: 'w-9 h-9 rounded-lg bg-white border border-slate-200 flex items-center justify-center text-slate-500 flex-shrink-0') do
          render PhlexIcons::Lucide::Gauge.new(class: 'w-[17px] h-[17px]')
        end
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-sm font-medium text-slate-700') { t('records.new_view.tank_debit.title') }
          p(class: 'text-xs text-slate-500 tabular-nums') do
            plain "#{t('records.new_view.tank_debit.balance')} "
            plain format_currency(@balance)
            plain ' → '
            span(data: { record_form_target: 'tankAfter' }) { format_currency(@balance - @expense.amount.to_d) }
          end
        end
      end
    end
  end
end

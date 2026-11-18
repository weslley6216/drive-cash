module Records
  class ExpenseFieldsComponent < ApplicationComponent
    def initialize(expense:)
      @expense = expense
    end

    def view_template
      render Records::CategoryPickerComponent.new(selected: @expense.category)
      render Records::DetailsSectionComponent.new do
        vendor_card
        description_card
      end
      div(class: 'mt-3 space-y-3') do
        paid_toggle
        yield if block_given?
      end
    end

    private

    def vendor_card
      div(class: Records::DetailsSectionComponent::CARD) do
        label(class: Records::DetailsSectionComponent::LABEL) { t('records.new_view.vendor_label') }
        input(type: 'text', name: 'record[vendor]', value: @expense.vendor,
              placeholder: t('records.new_view.vendor_placeholder'),
              class: 'w-full text-sm text-slate-800 bg-transparent focus:outline-none lg:mt-1 lg:font-medium lg:text-slate-900',
              data: { record_form_target: 'vendorInput',
                      action:             'input->record-form#refreshVendorUi' })
        vendor_inheritance_hint
      end
    end

    def vendor_inheritance_hint
      div(class: 'mt-2 hidden', data: { record_form_target: 'vendorHint' }) do
        div(class: 'flex items-center gap-2 text-xs text-slate-500') do
          span(class: 'inline-flex items-center gap-1.5 text-amber-600 font-medium') do
            span(class: 'w-1.5 h-1.5 rounded-full bg-amber-400')
            span { t('records.new_view.vendor_inherited') }
          end
          button(type: 'button', class: 'cursor-pointer text-slate-400 underline underline-offset-2 hover:text-slate-600',
                 data: { action: 'click->record-form#clearVendor' }) { t('records.new_view.vendor_clear') }
        end
      end
      div(class: 'mt-2 hidden', data: { record_form_target: 'vendorSuggest' }) do
        button(type:  'button',
               class: 'cursor-pointer inline-flex items-center gap-1.5 rounded-full border border-slate-200 bg-white px-3 py-1.5 text-xs font-medium text-slate-600 hover:border-slate-300 shadow-sm',
               data:  { action: 'click->record-form#applyVendor' }) do
          render PhlexIcons::Lucide::Fuel.new(class: 'w-3 h-3 text-amber-500')
          span(data: { record_form_target: 'vendorSuggestLabel' })
          span(class: 'text-slate-400') { "· #{t('records.new_view.vendor_from_tank')}" }
        end
      end
    end

    def description_card
      div(class: Records::DetailsSectionComponent::CARD) do
        label(class: Records::DetailsSectionComponent::LABEL) { t('records.new_view.description_label') }
        textarea(name: 'record[description]', rows: 2, class: 'w-full text-sm text-slate-800 bg-transparent focus:outline-none resize-none', placeholder: t('records.new_view.description_placeholder')) { @expense.description }
      end
    end

    def paid_toggle
      checked = @expense.new_record? ? true : !!@expense.paid
      div(class: 'bg-emerald-50 border border-emerald-200 rounded-xl px-4 py-3 flex items-center justify-between') do
        div do
          p(class: 'text-sm font-semibold text-emerald-900') { t('records.new_view.paid_toggle.title') }
          p(class: 'text-xs text-emerald-700') { t('records.new_view.paid_toggle.subtitle') }
        end
        label(class: 'relative inline-flex cursor-pointer items-center') do
          input(type: 'hidden', name: 'record[paid]', value: '0')
          input(type: 'checkbox', name: 'record[paid]', value: '1', checked: checked, class: 'peer sr-only')
          span(class: 'h-6 w-11 rounded-full bg-slate-300 transition-colors peer-checked:bg-emerald-500')
          span(class: 'pointer-events-none absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5')
        end
      end
    end
  end
end

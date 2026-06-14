module Records
  class EntryTypeToggleComponent < ApplicationComponent
    def initialize(active:)
      @active = active.to_s
    end

    def view_template
      div(class: 'bg-slate-100 rounded-xl p-1 flex') do
        option_button('earning', t('records.new_view.type_toggle.earning'), :truck, 'text-emerald-700')
        option_button('expense', t('records.new_view.type_toggle.expense'), :receipt, 'text-red-700')
      end
    end

    private

    def option_button(value, label, icon, active_text_class)
      is_active = @active == value
      label_classes = [
        'flex-1 py-2.5 rounded-lg text-sm font-semibold flex items-center justify-center gap-1.5 transition cursor-pointer',
        is_active ? "bg-white shadow-sm #{active_text_class}" : 'text-slate-500'
      ].join(' ')

      label(class: label_classes, data: { record_form_target: "#{value}Toggle" }) do
        input(
          type:    'radio',
          name:    'type',
          value:   value,
          checked: is_active,
          class:   'sr-only',
          data:    { record_form_target: 'typeInput', action: 'change->record-form#switch' }
        )
        render PhlexIcons::Lucide.const_get(icon.to_s.camelize).new(class: 'w-4 h-4')
        plain label
      end
    end
  end
end

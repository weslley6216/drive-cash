# frozen_string_literal: true

module FormFields
  def money_field(form, attribute, label:, required: false, calculator: false)
    field_wrapper(label) do
      render form.number_field(
        attribute,
        step: '0.01',
        required: required,
        placeholder: t('.placeholders.money'),
        value: form.object.send(attribute) || 0.00,
        class: input_classes,
        data: {
          calculator_target: 'input',
          action: 'focus->calculator#clearIfZero blur->calculator#resetIfEmpty input->calculator#calculate',
          type: calculator
        }
      )
    end
  end

  def field_wrapper(label_text)
    div(class: 'mb-4') do
      label(class: 'block text-sm font-medium text-slate-700 mb-2') { label_text }
      yield
    end
  end

  def input_classes
    'w-full px-4 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500'
  end
end

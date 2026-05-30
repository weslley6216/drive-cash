module Expenses
  class EditView < FormView
    private

    def selected_category = @expense.category

    def form_body(form)
      toggle_field(
        form,
        :paid,
        label: t('.labels.paid'),
        theme: @theme,
        on_label: t('.paid_states.on'),
        off_label: t('.paid_states.off')
      )
    end
  end
end

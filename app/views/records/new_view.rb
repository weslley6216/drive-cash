module Records
  class NewView < ApplicationView
    def initialize(type:, earning:, expense:, context: nil)
      @type = type
      @earning = earning
      @expense = expense
      @context = context || {}
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), app_shell: true) do
        div(data: { controller: 'record-form', record_form_type_value: @type }) do
          h1 { t('.title') }
        end
      end
    end
  end
end

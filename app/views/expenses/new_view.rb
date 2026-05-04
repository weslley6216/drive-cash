module Expenses
  class NewView < ApplicationView
    def initialize(expense:, context: {}, totals: nil, totals_context: {})
      @expense = expense
      @context = context || {}
      @theme = :red
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(class: modal_backdrop_classes, data: { controller: 'modal', action: 'mousedown->modal#handleBackgroundClick' }) do
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)}") do
            render_header(subtitle: t('.subtitle'))
            render_form
          end
        end
      end
    end

    private

    def render_form
      form_with(model: @expense, url: expenses_path, class: 'p-6 space-y-4') do |f|
        hidden_context_fields

        date_field(f, :date, label: t('.labels.date'), theme: @theme)
        money_field(f, :amount, label: t('.labels.amount'), theme: @theme, required: true)
        installment_section
        category_select(f)
        text_field(f, :vendor, label: t('.labels.vendor'), theme: @theme, placeholder: t('.placeholders.vendor'))
        text_area(f, :description, label: t('.labels.description'), theme: @theme, placeholder: t('.placeholders.description'), rows: 2)

        render_actions
      end
    end

    def hidden_context_fields
      input(type: 'hidden', name: 'context[year]', value: @context[:year])
      input(type: 'hidden', name: 'context[month]', value: @context[:month])
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

    def category_select(form)
      field_wrapper(t('.labels.category'), theme: @theme) do
        render form.select(
          :category,
          helpers.grouped_options_for_select(helpers.expense_category_options),
          { include_blank: t('.placeholders.select') },
          { class: "#{input_classes(theme: @theme)} bg-white", required: true }
        )
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data: { action: 'modal#close' }, class: button_classes(variant: :secondary, full_width: true)) { t('.buttons.cancel') }
        button(type: 'submit', class: "#{button_classes(variant: :danger, full_width: true)} flex items-center justify-center gap-2") do
          render PhlexIcons::Lucide::Save.new(class: 'w-5 h-5')
          span { t('.buttons.save') }
        end
      end
    end
  end
end

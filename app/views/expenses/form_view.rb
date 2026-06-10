module Expenses
  class FormView < ApplicationView
    def initialize(expense:, context: {})
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

    def form_url
      @expense.persisted? ? expense_path(@expense) : expenses_path
    end

    def form_method
      @expense.persisted? ? :patch : :post
    end

    def render_form
      form_with(model: @expense, url: form_url, method: form_method, class: 'p-6 space-y-4') do |f|
        hidden_context_fields

        date_field(f, :date, label: t('.labels.date'), theme: @theme)
        money_field(f, :amount, label: t('.labels.amount'), theme: @theme, required: true)
        form_body(f)
        category_select(f)
        text_field(f, :vendor, label: t('.labels.vendor'), theme: @theme, placeholder: t('.placeholders.vendor'))
        text_area(f, :description, label: t('.labels.description'), theme: @theme, placeholder: t('.placeholders.description'), rows: 2)
        refueling_extension

        render_actions
      end
    end

    def hidden_context_fields
      input(type: 'hidden', name: 'context[year]', value: @context[:year])
      input(type: 'hidden', name: 'context[month]', value: @context[:month])
    end

    def category_select(form)
      field_wrapper(t('.labels.category'), theme: @theme) do
        render form.select(
          :category,
          helpers.grouped_options_for_select(helpers.expense_category_options, selected_category),
          { include_blank: t('.placeholders.select') },
          { class: "#{input_classes(theme: @theme)} bg-white", required: true }
        )
      end
    end

    def selected_category = nil

    def refueling_extension
      div(class: 'mt-2') do
        details(class: 'border border-slate-200 rounded-lg p-3 bg-slate-50') do
          summary(class: 'text-sm font-medium text-slate-700 cursor-pointer') { t('expenses.refueling_extension.heading') }
          div(class: 'mt-3 space-y-3') do
            refueling_label_input(:liters, t('expenses.refueling_extension.labels.liters'), type: 'text', placeholder: '32,5', inputmode: 'decimal')
            refueling_label_input(:odometer_km, t('expenses.refueling_extension.labels.odometer_km'), type: 'number', placeholder: '48230')
            refueling_checkbox_input(:full_tank, t('expenses.refueling_extension.labels.full_tank'))
          end
        end
      end
    end

    def refueling_label_input(field, label_text, **input_options)
      div do
        label(class: 'block text-xs font-medium text-slate-600 mb-1') { label_text }
        input(name: "refueling[#{field}]",
              class: 'w-full px-3 py-2 rounded-lg border border-slate-300 focus:ring-2 focus:ring-red-500 focus:border-red-500 text-sm',
              **input_options)
      end
    end

    def refueling_checkbox_input(field, label_text)
      label(class: 'inline-flex items-center gap-2 text-sm text-slate-700') do
        input(type: 'hidden', name: "refueling[#{field}]", value: '0')
        input(type: 'checkbox', name: "refueling[#{field}]", value: '1', checked: true,
              class: 'rounded border-slate-300 text-red-600 focus:ring-red-500')
        span { label_text }
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

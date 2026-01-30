module Expenses
  class NewView < ApplicationView
    def initialize(expense:, context: {})
      @expense = expense
      @context = context || {}
      @theme = :red
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(class: modal_backdrop_classes, data_controller: 'modal', data_action: 'mousedown->modal#handleBackgroundClick') do
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)}") do
            render_header(subtitle: t('.subtitle'))
            render_form
          end
        end
      end
    end

    private

    def render_form
      form_with(model: @expense, url: expenses_path, class: 'p-6 space-y-4', data: { controller: 'calculator' }) do |f|
        hidden_context_fields

        date_field(f, :date, label: t('.labels.date'), theme: @theme)
        money_field(f, :amount, label: t('.labels.amount'), theme: @theme, required: true, calculator: 'cost')
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

    def category_select(form)
      field_wrapper(t('.labels.category'), theme: @theme) do
        render form.select(
          :category,
          helpers.grouped_options_for_select(Expense.grouped_category_options),
          { include_blank: t('.placeholders.select') },
          { class: "#{input_classes(theme: @theme)} bg-white", required: true }
        )
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data_action: 'modal#close', class: button_classes(variant: :secondary, full_width: true)) { t('.buttons.cancel') }
        button(type: 'submit', class: "#{button_classes(variant: :danger, full_width: true)} flex items-center justify-center gap-2") do
          render PhlexIcons::Lucide::Save.new(class: 'w-5 h-5')
          span { t('.buttons.save') }
        end
      end
    end
  end
end

module Earnings
  class FormView < ApplicationView
    def initialize(earning:, context: {})
      @earning = earning
      @context = context || {}
      @theme = :blue
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
      @earning.persisted? ? earning_path(@earning) : earnings_path
    end

    def form_method
      @earning.persisted? ? :patch : :post
    end

    def render_form
      form_with(model: @earning, url: form_url, method: form_method, class: 'p-6 space-y-4') do |form|
        hidden_context_fields

        date_field(form, :date, label: t('.labels.date'), theme: @theme)
        money_field(form, :amount, label: t('.labels.amount'), theme: @theme, required: true)
        platform_select(form)
        text_area(form, :notes, label: t('.labels.notes'), theme: @theme, placeholder: t('.placeholders.notes'), rows: 2)
        integer_field(form, :trips_count, label: t('.labels.trips_count'), theme: @theme, required: true)

        render_actions
      end
    end

    def hidden_context_fields
      input(type: 'hidden', name: 'context[year]', value: @context[:year])
      input(type: 'hidden', name: 'context[month]', value: @context[:month])
    end

    def platform_select(form)
      field_wrapper(t('.labels.platform'), theme: @theme) do
        render form.select(
          :platform,
          Earning.platforms.keys.map { |key| [Earning.human_enum_name(:platform, key), key] },
          { include_blank: t('.placeholders.select') },
          { class: "#{input_classes(theme: @theme)} bg-white", required: true }
        )
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data: { action: 'modal#close' }, class: button_classes(variant: :secondary, full_width: true)) { t('.buttons.cancel') }
        button(type: 'submit', class: "#{button_classes(variant: :primary, full_width: true)} flex items-center justify-center gap-2",
               data: { turbo_submits_with: t('.buttons.saving') }) do
          render PhlexIcons::Lucide::Save.new(class: 'w-5 h-5')
          span { t('.buttons.save') }
        end
      end
    end
  end
end

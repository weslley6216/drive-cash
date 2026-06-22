module Refuelings
  class FormView < ApplicationView
    def initialize(refueling:)
      @refueling = refueling
      @theme = :red
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(class: modal_backdrop_classes, data: { controller: 'modal', action: 'mousedown->modal#handleBackgroundClick' }) do
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)}") do
            render_header
            render_form
          end
        end
      end
    end

    private

    def render_header
      div(class: modal_header_classes) do
        h2(class: "#{modal_title_classes} #{title_classes(theme: @theme)}") { title_text }
        button(type: 'button', data: { action: 'modal#close' }, class: modal_close_button_classes) { '×' }
      end
    end

    def title_text
      @refueling.persisted? ? t('refuelings.form.title_edit') : t('refuelings.form.title_new')
    end

    def form_url
      @refueling.persisted? ? helpers.refueling_path(@refueling) : helpers.refuelings_path
    end

    def form_method
      @refueling.persisted? ? :patch : :post
    end

    def render_form
      form_with(model: @refueling, url: form_url, method: form_method, class: 'p-6 space-y-4') do |form|
        date_field(form, :date, label: t('refuelings.form.labels.date'), theme: @theme)
        text_field(form, :vendor, label: t('refuelings.form.labels.vendor'), theme: @theme, placeholder: t('refuelings.form.placeholders.vendor'))
        money_field(form, :liters, label: t('refuelings.form.labels.liters'), theme: @theme, required: true)
        money_field(form, :total_amount, label: t('refuelings.form.labels.total_amount'), theme: @theme, required: true)
        odometer_field_with_preview(form)
        toggle_field(form, :full_tank, label: t('refuelings.form.labels.full_tank'), theme: @theme)
        render_actions
      end
    end

    def odometer_field_with_preview(form)
      div(data: { controller:                        'odometer-preview',
                  odometer_preview_current_km_value: @refueling.vehicle.odometer_km.to_i }) do
        integer_field(form, :odometer_km, label: t('refuelings.form.labels.odometer_km'), theme: @theme)
        odometer_preview_cards
      end
    end

    def odometer_preview_cards
      current_formatted = helpers.number_with_delimiter(@refueling.vehicle.odometer_km.to_i)

      div(class: 'mt-2.5 hidden rounded-xl bg-blue-50 border border-blue-200 p-3 flex items-start gap-2.5',
          data:  { odometer_preview_target: 'advance' }) do
        div(class: 'w-7 h-7 rounded-full bg-blue-500/15 flex items-center justify-center flex-shrink-0 mt-0.5') do
          render PhlexIcons::Lucide::Gauge.new(class: 'w-4 h-4 text-blue-700')
        end
        div(class: 'min-w-0') do
          p(class: 'text-sm font-semibold text-blue-900') { t('refuelings.form.odometer_preview.title_advance') }
          p(class: 'text-xs text-blue-800 mt-0.5 tabular-nums', data: { odometer_preview_target: 'advanceLine' })
        end
      end

      div(class: 'mt-2.5 hidden rounded-xl bg-amber-50 border border-amber-200 p-3 flex items-start gap-2.5',
          data:  { odometer_preview_target: 'warn' }) do
        render PhlexIcons::Lucide::TriangleAlert.new(class: 'w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5')
        p(class: 'text-xs text-amber-800 leading-snug') do
          t('refuelings.form.odometer_preview.cannot_recede', current: current_formatted)
        end
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data: { action: 'modal#close' }, class: button_classes(variant: :secondary, full_width: true)) { t('refuelings.form.buttons.cancel') }
        button(type: 'submit', class: button_classes(variant: :danger, full_width: true),
               data: { turbo_submits_with: t('refuelings.form.buttons.saving') }) { t('refuelings.form.buttons.save') }
      end
    end
  end
end

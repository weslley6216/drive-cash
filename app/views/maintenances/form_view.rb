module Maintenances
  class FormView < ApplicationView
    def initialize(maintenance:)
      @maintenance = maintenance
      @theme = :blue
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
      @maintenance.persisted? ? t('maintenances.form.title_edit') : t('maintenances.form.title_new')
    end

    def form_url
      @maintenance.persisted? ? helpers.maintenance_path(@maintenance) : helpers.maintenances_path
    end

    def form_method
      @maintenance.persisted? ? :patch : :post
    end

    def render_form
      form_with(model: @maintenance, url: form_url, method: form_method, class: 'p-6 space-y-4') do |form|
        text_field(form, :name, label: t('maintenances.form.labels.name'), theme: @theme, placeholder: t('maintenances.form.placeholders.name'))
        category_select(form)
        integer_field(form, :due_at_km, label: t('maintenances.form.labels.due_at_km'), theme: @theme)
        date_field(form, :due_at_date, label: t('maintenances.form.labels.due_at_date'), theme: @theme)
        money_field(form, :estimated_cost, label: t('maintenances.form.labels.estimated_cost'), theme: @theme)
        toggle_field(form, :completed, label: t('maintenances.form.labels.completed'), theme: @theme) if @maintenance.persisted?
        render_actions
      end
    end

    def category_select(form)
      field_wrapper(t('maintenances.form.labels.category'), theme: @theme) do
        options = Maintenance.categories.keys.map { |category| [t("maintenances.form.categories.#{category}"), category] }
        render form.select(:category, options, {}, { class: "#{input_classes(theme: @theme)} bg-white", required: true })
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data: { action: 'modal#close' }, class: button_classes(variant: :secondary, full_width: true)) { t('maintenances.form.buttons.cancel') }
        button(type: 'submit', class: button_classes(variant: :primary, full_width: true)) { t('maintenances.form.buttons.save') }
      end
    end
  end
end

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
        category_select(form) unless @maintenance.persisted?
        integer_field(form, :interval_km, label: t('maintenances.form.labels.interval_km'), theme: @theme, help: interval_help)
        integer_field(form, :last_done_km, label: t('maintenances.form.labels.last_done_km'), theme: @theme, help: last_done_km_help)
        money_field(form, :estimated_cost, label: t('maintenances.form.labels.estimated_cost'), theme: @theme, help: estimated_cost_help)
        render_actions
        render_remove if @maintenance.persisted?
      end
    end

    def category_select(form)
      field_wrapper(t('maintenances.form.labels.category'), theme: @theme) do
        options = @maintenance.selectable_categories.map { |category| [t("vehicle.maintenances.catalog.#{category}"), category] }
        render form.select(:category, options, {}, { class: "#{input_classes(theme: @theme)} bg-white", required: true })
      end
    end

    def interval_help
      return unless @maintenance.persisted?

      default_km = Maintenance.catalog_defaults(@maintenance.category)[:interval_km]
      t('maintenances.form.help.interval_catalog', km: helpers.number_with_delimiter(default_km, delimiter: '.'))
    end

    def last_done_km_help
      t('maintenances.form.help.last_done_km') if @maintenance.persisted?
    end

    def estimated_cost_help
      t('maintenances.form.help.estimated_cost') if @maintenance.persisted?
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data: { action: 'modal#close' }, class: button_classes(variant: :secondary, full_width: true)) { t('maintenances.form.buttons.cancel') }
        button(type: 'submit', class: button_classes(variant: :primary, full_width: true),
               data: { turbo_submits_with: t('maintenances.form.buttons.saving') }) { t('maintenances.form.buttons.save') }
      end
    end

    def render_remove
      render ConfirmActionComponent.new(
        title:         t('maintenances.form.remove_confirm'),
        icon:          PhlexIcons::Lucide::Trash2,
        confirm_path:  helpers.maintenance_path(@maintenance),
        confirm_label: t('maintenances.form.remove'),
        cancel_label:  t('maintenances.form.buttons.cancel'),
        description:   t('maintenances.form.remove_description')
      ) do
        button(type:  'button',
               class: 'w-full h-11 rounded-xl text-sm font-semibold text-red-600 flex items-center justify-center gap-1.5',
               data:  { action: 'click->confirm-action#open' }) do
          render PhlexIcons::Lucide::Trash2.new(class: 'w-[15px] h-[15px]')
          plain t('maintenances.form.remove')
        end
      end
    end
  end
end

module Vehicles
  class EditView < ApplicationView
    def initialize(vehicle:)
      @vehicle = vehicle
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
        h2(class: "#{modal_title_classes} #{title_classes(theme: @theme)}") { t('vehicle.form.edit_title') }
        button(type: 'button', data: { action: 'modal#close' }, class: modal_close_button_classes) { '×' }
      end
    end

    def render_form
      form_with(model: @vehicle, url: helpers.vehicle_path, method: :patch, class: 'p-6 space-y-4') do |form|
        integer_field(form, :odometer_km, label: t('vehicle.registration.labels.odometer_km'), theme: @theme)
        render_actions
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data: { action: 'modal#close' }, class: button_classes(variant: :secondary, full_width: true)) { t('vehicle.form.cancel') }
        button(type: 'submit', class: button_classes(variant: :primary, full_width: true)) { t('vehicle.form.submit') }
      end
    end
  end
end

class Vehicle
  class RegistrationFormComponent < ApplicationComponent
    include Phlex::Rails::Helpers::FormWith

    def initialize(vehicle:)
      @vehicle = vehicle
    end

    def view_template
      div(class: 'bg-white rounded-2xl border border-slate-200 p-6 max-w-md mx-auto') do
        h2(class: 'text-lg font-semibold text-slate-800 mb-4') { t('vehicle.registration.title') }
        errors_block if @vehicle.errors.any?
        form_with(model: @vehicle, url: helpers.vehicle_path, method: :patch, class: 'space-y-4') do |form|
          text_input(form, :brand)
          text_input(form, :vehicle_model)
          number_input(form, :year)
          text_input(form, :license_plate, required: false)
          number_input(form, :odometer_km)
          submit_row(form)
        end
      end
    end

    private

    def errors_block
      div(class: 'mb-4 rounded-lg border border-red-200 bg-red-50 p-3 text-xs text-red-800', data: { testid: 'vehicle-form-errors' }) do
        ul do
          @vehicle.errors.full_messages.each do |message|
            li(class: 'error') { message }
          end
        end
      end
    end

    def text_input(form, attribute, required: true)
      div do
        label(class: 'block text-sm font-medium text-slate-700 mb-1') { t("vehicle.registration.labels.#{attribute}") }
        render form.text_field(attribute, required: required,
                                          class: 'w-full px-3 py-2 rounded-lg border border-slate-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500')
      end
    end

    def number_input(form, attribute)
      div do
        label(class: 'block text-sm font-medium text-slate-700 mb-1') { t("vehicle.registration.labels.#{attribute}") }
        render form.number_field(attribute, required: true, step: 1,
                                            class: 'w-full px-3 py-2 rounded-lg border border-slate-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500')
      end
    end

    def submit_row(form)
      div(class: 'pt-2') do
        render form.submit(t('vehicle.registration.submit'),
                           class: 'w-full bg-blue-600 hover:bg-blue-700 text-white font-medium px-4 py-2 rounded-lg cursor-pointer')
      end
    end
  end
end

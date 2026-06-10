require 'rails_helper'

RSpec.describe Vehicle::RegistrationFormComponent, type: :component do
  describe '#view_template' do
    it 'renders title and labels' do
      vehicle = Vehicle.new

      html = view_context.render(described_class.new(vehicle: vehicle))

      expect(html).to include(I18n.t('vehicle.registration.title'))
      expect(html).to include(I18n.t('vehicle.registration.labels.brand'))
      expect(html).to include(I18n.t('vehicle.registration.labels.vehicle_model'))
      expect(html).to include(I18n.t('vehicle.registration.labels.year'))
      expect(html).to include(I18n.t('vehicle.registration.labels.odometer_km'))
    end

    it 'renders submit button' do
      html = view_context.render(described_class.new(vehicle: Vehicle.new))

      expect(html).to include(I18n.t('vehicle.registration.submit'))
    end

    it 'renders existing values when vehicle has them' do
      vehicle = Vehicle.new(brand: 'Honda', vehicle_model: 'Civic', year: 2018, odometer_km: 48_230)

      html = view_context.render(described_class.new(vehicle: vehicle))

      expect(html).to include('Honda')
      expect(html).to include('Civic')
      expect(html).to include('2018')
    end

    it 'renders validation errors when present' do
      vehicle = Vehicle.new
      vehicle.valid?

      html = view_context.render(described_class.new(vehicle: vehicle))

      expect(html).to include('error')
    end
  end
end

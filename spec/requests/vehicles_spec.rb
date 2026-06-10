require 'rails_helper'

RSpec.describe 'Vehicles', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /vehicle' do
    context 'without a vehicle' do
      it 'renders the registration form' do
        get vehicle_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t('vehicle.registration.title'))
      end
    end

    context 'with a vehicle' do
      let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 48_230) }

      before { vehicle }

      it 'renders the dashboard with odometer' do
        get vehicle_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('48.230')
      end

      it 'renders metric labels' do
        get vehicle_path

        expect(response.body).to include(I18n.t('vehicle.metrics.cost_per_km'))
        expect(response.body).to include(I18n.t('vehicle.metrics.revenue_per_km'))
        expect(response.body).to include(I18n.t('vehicle.metrics.km_per_liter'))
      end
    end
  end

  describe 'PATCH /vehicle' do
    context 'without an existing vehicle (registration)' do
      it 'creates the vehicle for the current user' do
        patch vehicle_path, params: { vehicle: { brand: 'Honda', vehicle_model: 'Civic', year: 2018,
                                                 license_plate: 'ABC-1D23', odometer_km: 48_230 } }

        expect(current_user.reload.vehicle).to be_present
        expect(response).to redirect_to(vehicle_path)
      end

      it 'rerenders the form on invalid params' do
        patch vehicle_path, params: { vehicle: { brand: '', vehicle_model: '', year: '', odometer_km: '' } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t('vehicle.registration.title'))
      end
    end

    context 'with an existing vehicle (update)' do
      let(:vehicle) { create(:vehicle, user: current_user) }

      before { vehicle }

      it 'updates the odometer and redirects' do
        patch vehicle_path, params: { vehicle: { odometer_km: 49_000 } }

        expect(vehicle.reload.odometer_km).to eq(49_000)
        expect(response).to redirect_to(vehicle_path)
      end

      it 'rerenders the dashboard on invalid update' do
        patch vehicle_path, params: { vehicle: { odometer_km: -1 } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end

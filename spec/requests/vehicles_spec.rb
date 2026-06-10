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

    context 'with a vehicle, maintenances, refuelings, and insights' do
      let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 50_000) }

      before do
        vehicle
        create(:maintenance, vehicle: vehicle, name: 'Troca de óleo', due_at_km: 51_000)
        liters_by_vendor = { 'PosA' => 40, 'PosB' => 38, 'PosC' => 30 }
        liters_by_vendor.each_with_index do |(vendor, liters), vendor_index|
          2.times do |refueling_index|
            create(:refueling, vehicle: vehicle, vendor: vendor,
                               full_tank: true, liters: liters,
                               total_amount: 180,
                               odometer_km: 46_000 + (vendor_index * 1000) + (refueling_index * 400),
                               date: Date.current - (30 - vendor_index - refueling_index).days)
          end
        end
      end

      it 'renders maintenance cards when maintenances exist' do
        get vehicle_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Troca de óleo')
      end

      it 'renders refueling rows when refuelings exist' do
        get vehicle_path

        expect(response.body).to include(I18n.t('vehicle.refuelings.title'))
      end

      it 'renders the insight card when insights exist' do
        get vehicle_path

        expect(response.body).to include(I18n.t('vehicle.insights.cheapest_vendor.title', vendor: 'PosC'))
      end
    end
  end

  describe 'GET /vehicle/edit' do
    let(:vehicle) { create(:vehicle, user: current_user) }

    before { vehicle }

    it 'renders the odometer edit modal' do
      get edit_vehicle_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('vehicle.form.edit_title'))
      expect(response.body).to include('turbo-frame id="modal"')
    end

    it 'renders the form even without a vehicle' do
      get edit_vehicle_path

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /vehicle' do
    context 'without an existing vehicle (registration)' do
      it 'creates the vehicle and responds with turbo refresh and modal clear' do
        patch vehicle_path,
              params: { vehicle: { brand: 'Honda', vehicle_model: 'Civic', year: 2018,
                                   license_plate: 'ABC-1D23', odometer_km: 48_230 } },
              as: :turbo_stream

        expect(current_user.reload.vehicle).to be_present
        expect(response.body).to include('action="update"').and include('action="refresh"')
      end

      it 'redirects html to /vehicle after registration' do
        patch vehicle_path, params: { vehicle: { brand: 'Honda', vehicle_model: 'Civic',
                                                 year: 2018, odometer_km: 48_230 } }

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

      it 'updates the odometer and responds with turbo refresh and modal clear' do
        patch vehicle_path, params: { vehicle: { odometer_km: 49_000 } }, as: :turbo_stream

        expect(vehicle.reload.odometer_km).to eq(49_000)
        expect(response.body).to include('action="update"').and include('action="refresh"')
      end

      it 'redirects html to /vehicle after update' do
        patch vehicle_path, params: { vehicle: { odometer_km: 49_000 } }

        expect(response).to redirect_to(vehicle_path)
      end

      it 'rerenders the dashboard on invalid update' do
        patch vehicle_path, params: { vehicle: { odometer_km: -1 } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end

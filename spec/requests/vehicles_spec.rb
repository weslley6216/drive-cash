require 'rails_helper'

RSpec.describe 'Vehicles', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /vehicle' do
    context 'without a vehicle' do
      it 'renders the empty state with the registration form' do
        get vehicle_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t('vehicle.empty.title'))
        expect(response.body).to include(I18n.t('vehicle.registration.title'))
      end
    end

    context 'with a vehicle' do
      let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 160_928) }

      before { vehicle }

      it 'renders the dashboard with odometer and tank sections' do
        get vehicle_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include('160.928')
        expect(response.body).to include(I18n.t('vehicle.tank.title'))
        expect(response.body).to include(I18n.t('vehicle.moves.title'))
      end
    end

    context 'with maintenances, refuelings and insights' do
      let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 160_928) }

      before do
        vehicle
        create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 158_318, interval_km: 5_000)
        liters_by_vendor = { 'PosA' => 40, 'PosB' => 38, 'PosC' => 30 }
        liters_by_vendor.each_with_index do |(vendor, liters), vendor_index|
          2.times do |refueling_index|
            create(:refueling, vehicle: vehicle, vendor: vendor,
                               full_tank: true, liters: liters,
                               total_amount: 180,
                               odometer_km: 156_000 + (vendor_index * 1000) + (refueling_index * 400),
                               date: Date.current - (30 - vendor_index - refueling_index).days)
          end
        end
      end

      it 'renders the maintenance catalog label when maintenances exist' do
        get vehicle_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t('vehicle.maintenances.catalog.oil_change'))
      end

      it 'renders the insight card when insights exist' do
        get vehicle_path

        expect(response.body).to include(I18n.t('vehicle.insight.cheapest.title', vendor: 'PosC'))
      end
    end

    context 'with more maintenances than the mobile limit' do
      let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 160_928) }

      before do
        vehicle
        Maintenance::CATALOG.keys.first(6).each do |kind|
          create(:maintenance, vehicle: vehicle, category: kind, last_done_km: 159_000, interval_km: 5_000)
        end
      end

      it 'shows the hidden on-track counter on the catalog button' do
        get vehicle_path

        expect(response.body).to include(I18n.t('vehicle.maintenances.hidden_ok', count: 1))
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
              as:     :turbo_stream

        expect(current_user.reload.vehicle).to be_present
        expect(response.body).to include('action="update"').and include('action="refresh"')
      end

      it 'rerenders the form on invalid params' do
        patch vehicle_path, params: { vehicle: { brand: '', vehicle_model: '', year: '', odometer_km: '' } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t('vehicle.registration.title'))
      end
    end

    context 'with an existing vehicle (update)' do
      let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 48_230, odometer_updated_at: nil) }

      before { vehicle }

      it 'updates the odometer and stamps the freshness timestamp' do
        patch vehicle_path, params: { vehicle: { odometer_km: 49_000 } }, as: :turbo_stream

        expect(vehicle.reload.odometer_km).to eq(49_000)
        expect(vehicle.odometer_updated_at).to be_present
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

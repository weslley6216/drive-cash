require 'rails_helper'

RSpec.describe 'Maintenances', type: :request do
  let(:current_user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 160_928) }

  before do
    vehicle
    login_as(current_user)
  end

  describe 'GET /maintenances/new' do
    it 'renders the modal form' do
      get new_maintenance_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('maintenances.form.title_new'))
    end
  end

  describe 'POST /maintenances' do
    let(:valid_params) do
      { maintenance: { category: 'oil_change', last_done_km: 158_318, interval_km: 5_000, estimated_cost: '280.00' } }
    end

    it 'creates a maintenance and responds with modal clear and turbo_stream refresh' do
      post maintenances_path, params: valid_params, as: :turbo_stream

      expect(Maintenance.count).to eq(1)
      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include('action="update"').and include('action="refresh"')
    end

    it 'fills interval and cost from the catalog when left blank' do
      post maintenances_path, params: { maintenance: { category: 'timing_belt', last_done_km: 110_000 } }, as: :turbo_stream

      maintenance = Maintenance.last
      expect(maintenance.interval_km).to eq(60_000)
      expect(maintenance.estimated_cost).to eq(900)
    end

    it 'rerenders form on invalid params' do
      post maintenances_path, params: { maintenance: { category: 'oil_change', last_done_km: '' } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('maintenances.form.title_new'))
    end
  end

  describe 'GET /maintenances/:id/edit' do
    let(:maintenance) { create(:maintenance, vehicle: vehicle) }

    it 'renders the edit modal form' do
      get edit_maintenance_path(maintenance)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('maintenances.form.title_edit'))
    end
  end

  describe 'PATCH /maintenances/:id' do
    let(:maintenance) { create(:maintenance, vehicle: vehicle, interval_km: 5_000) }

    it 'updates the interval and refreshes via turbo' do
      patch maintenance_path(maintenance), params: { maintenance: { interval_km: 8_000 } }, as: :turbo_stream

      expect(maintenance.reload.interval_km).to eq(8_000)
      expect(response.body).to include('action="refresh"')
    end

    it 'rerenders the form on invalid update' do
      patch maintenance_path(maintenance), params: { maintenance: { interval_km: '' } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('maintenances.form.title_edit'))
    end
  end

  describe 'PATCH /maintenances/:id/mark_done' do
    let(:maintenance) { create(:maintenance, vehicle: vehicle, last_done_km: 150_000, interval_km: 5_000) }

    it 'resets last_done_km to the current odometer so progress zeroes out' do
      patch mark_done_maintenance_path(maintenance), as: :turbo_stream

      expect(maintenance.reload.last_done_km).to eq(160_928)
      expect(maintenance.progress).to eq(0)
      expect(response.body).to include('action="refresh"')
    end

    it 'rerenders with an error flash when marking done fails validation' do
      vehicle.update!(odometer_km: 0)
      maintenance = create(:maintenance, vehicle: vehicle, last_done_km: 100)

      patch mark_done_maintenance_path(maintenance), as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(maintenance.reload.last_done_km).to eq(100)
    end
  end

  describe 'DELETE /maintenances/:id' do
    let(:maintenance) { create(:maintenance, vehicle: vehicle) }

    before { maintenance }

    it 'destroys and redirects' do
      expect { delete maintenance_path(maintenance) }.to change(Maintenance, :count).by(-1)

      expect(response).to redirect_to(vehicle_path)
    end

    it 'returns 404 for other user maintenance' do
      other = create(:vehicle)
      foreign = create(:maintenance, vehicle: other)

      delete maintenance_path(foreign)

      expect(response).to have_http_status(:not_found)
    end
  end
end

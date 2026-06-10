require 'rails_helper'

RSpec.describe 'Maintenances', type: :request do
  let(:current_user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: current_user) }

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
      { maintenance: { name: 'Troca de óleo', category: 'oil_change',
                       due_at_km: 49_000, due_at_date: (Date.current + 18.days).to_s,
                       estimated_cost: '180.00' } }
    end

    it 'creates a maintenance and refreshes via turbo_stream' do
      post maintenances_path, params: valid_params, as: :turbo_stream

      expect(Maintenance.count).to eq(1)
      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include('action="refresh"')
    end

    it 'rerenders form on invalid params' do
      post maintenances_path, params: { maintenance: { name: '' } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('maintenances.form.title_new'))
    end

    it 'redirects html to /vehicle' do
      post maintenances_path, params: valid_params

      expect(response).to redirect_to(vehicle_path)
    end
  end

  describe 'PATCH /maintenances/:id' do
    let(:maintenance) { create(:maintenance, vehicle: vehicle, completed: false) }

    it 'marks as completed when params include completed=true' do
      patch maintenance_path(maintenance), params: { maintenance: { completed: '1' } }, as: :turbo_stream

      expect(maintenance.reload.completed).to be(true)
    end

    it 'rerenders form on invalid update' do
      patch maintenance_path(maintenance), params: { maintenance: { name: '' } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
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

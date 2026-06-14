require 'rails_helper'

RSpec.describe 'Refuelings', type: :request do
  let(:current_user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: current_user) }

  before do
    vehicle
    login_as(current_user)
  end

  describe 'GET /refuelings/new' do
    it 'renders the modal form' do
      get new_refueling_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('refuelings.form.title_new'))
    end
  end

  describe 'POST /refuelings' do
    let(:valid_params) do
      { refueling: { date: Date.current.to_s, vendor: 'Posto Orense',
                     liters: '32,5', total_amount: '180,50', odometer_km: 48_230,
                     full_tank: '1' } }
    end

    it 'creates a refueling and responds with modal clear and turbo_stream refresh' do
      post refuelings_path, params: valid_params, as: :turbo_stream

      expect(Refueling.count).to eq(1)
      expect(response.body).to include('action="update"').and include('action="refresh"')
    end

    it 'rerenders form on invalid params' do
      post refuelings_path, params: { refueling: { liters: '' } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'redirects html to /vehicle' do
      post refuelings_path, params: valid_params

      expect(response).to redirect_to(vehicle_path)
    end
  end

  describe 'GET /refuelings/:id/edit' do
    let(:refueling) { create(:refueling, vehicle: vehicle) }

    it 'renders the edit modal form' do
      get edit_refueling_path(refueling)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('refuelings.form.title_edit'))
    end
  end

  describe 'PATCH /refuelings/:id' do
    let(:refueling) { create(:refueling, vehicle: vehicle) }

    it 'updates and refreshes' do
      patch refueling_path(refueling), params: { refueling: { liters: '30,0' } }, as: :turbo_stream

      expect(refueling.reload.liters).to eq(30.0)
    end

    it 'rerenders form on invalid update' do
      patch refueling_path(refueling), params: { refueling: { total_amount: '' } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'DELETE /refuelings/:id' do
    let(:refueling) { create(:refueling, vehicle: vehicle) }

    before { refueling }

    it 'destroys and redirects' do
      expect { delete refueling_path(refueling) }.to change(Refueling, :count).by(-1)

      expect(response).to redirect_to(vehicle_path)
    end

    it 'returns 404 for other user refueling' do
      other = create(:vehicle)
      foreign = create(:refueling, vehicle: other)

      delete refueling_path(foreign)

      expect(response).to have_http_status(:not_found)
    end
  end
end

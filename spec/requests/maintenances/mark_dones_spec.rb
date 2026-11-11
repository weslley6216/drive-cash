require 'rails_helper'

RSpec.describe 'Maintenances::MarkDones', type: :request do
  let(:current_user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: current_user, odometer_km: 160_928) }
  let(:oil) { create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 155_600) }
  let(:filter) { create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 150_800) }

  before do
    oil
    filter
    login_as(current_user)
  end

  describe 'GET /maintenances/:maintenance_id/mark_done/new' do
    it 'renders the form' do
      get new_maintenance_mark_done_path(oil)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('maintenances.mark_done.title', item: 'Troca de óleo'))
    end

    it 'returns 404 for another user maintenance' do
      foreign = create(:maintenance)

      get new_maintenance_mark_done_path(foreign)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /maintenances/:maintenance_id/mark_done' do
    it 'updates the item and selected companions, responds with modal clear and refresh, and sets the undo flash' do
      patch maintenance_mark_done_path(oil), params: { mark_done: { done_km: 160_928, companion_ids: [filter.id] } }, as: :turbo_stream

      expect(oil.reload.last_done_km).to eq(160_928)
      expect(filter.reload.last_done_km).to eq(160_928)
      expect(response.body).to include('action="update"').and include('action="refresh"')
      expect(flash[:undo]['restore']).to eq({ oil.id.to_s => 155_600, filter.id.to_s => 150_800 })
    end

    it 'rerenders with the below_last error and keeps the km when done_km is below the last one' do
      patch maintenance_mark_done_path(oil), params: { mark_done: { done_km: 154_900 } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('maintenances.mark_done.errors.below_last', km: '155.600'))
      expect(oil.reload.last_done_km).to eq(155_600)
    end

    it 'rerenders with status 422 when done_km is blank' do
      patch maintenance_mark_done_path(oil), params: { mark_done: { done_km: '' } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'syncs the odometer with the given done_on when done_km is ahead' do
      patch maintenance_mark_done_path(oil), params: { mark_done: { done_km: 161_150, done_on: '2026-11-09' } }, as: :turbo_stream

      expect(vehicle.reload.odometer_updated_at.to_date).to eq(Date.new(2026, 11, 9))
    end
  end

  describe 'DELETE /maintenances/:maintenance_id/mark_done' do
    it 'restores the previous km and redirects with the undone notice' do
      oil.update!(last_done_km: 160_928)

      delete maintenance_mark_done_path(oil), params: { restore: { oil.id => 155_600 } }, as: :turbo_stream

      expect(oil.reload.last_done_km).to eq(155_600)
      expect(flash[:notice]).to eq(I18n.t('maintenances.mark_done.undone'))
      expect(response.body).to include('action="refresh"')
    end

    it 'sets the undo_failed alert when a restored value is invalid' do
      delete maintenance_mark_done_path(oil), params: { restore: { oil.id => 0 } }, as: :turbo_stream

      expect(flash[:alert]).to eq(I18n.t('maintenances.mark_done.undo_failed'))
    end
  end
end

require 'rails_helper'

RSpec.describe 'Earnings', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'retired earning routes' do
    it 'no longer serves the old new earning form' do
      get '/earnings/new'

      expect(response).to have_http_status(:not_found)
    end

    it 'no longer creates earnings outside the records form' do
      expect {
        post '/earnings', params: { earning: { date: '2026-01-23', amount: 200, platform: 'uber', trips_count: 2 } }, as: :turbo_stream
      }.not_to change(Earning, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /earnings/:id/edit' do
    it 'renders the new record form prefilled inside the modal frame with the earning theme and no type toggle' do
      earning = create(:earning, user: current_user, date: Date.new(2026, 1, 10), amount: 120, platform: 'uber', trips_count: 3, notes: 'Bônus de domingo')

      get edit_earning_path(earning), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('records.edit_view.title'))
      expect(response.body).to include('data-record-form-type-value="earning"')
      expect(response.body).to include(%(action="#{earning_path(earning)}"))
      expect(response.body).to include('name="_method" value="patch"')
      expect(response.body).to include('value="uber" checked')
      expect(response.body).to include('name="record[trips_count]" value="3"')
      expect(response.body).to include('Bônus de domingo')
      expect(response.body).to include('value="2026"')
      expect(response.body).to include(I18n.t('records.new_view.save_earning'))
      expect(response.body).not_to include('data-record-form-target="expenseToggle"')
      expect(response.body).not_to include('Translation missing')
    end

    it 'offers to delete the earning returning to the period it came from' do
      earning = create(:earning, user: current_user, date: Date.new(2026, 1, 10))

      get edit_earning_path(earning), params: { context: { year: 2026, month: 1 } }

      expect(response.body).to include(I18n.t('records.edit_view.delete'))
      expect(response.body).to include(%(action="#{earning_path(earning, context: { year: '2026', month: '1' })}"))
      expect(response.body).to include('name="_method" value="delete"')
    end
  end

  describe 'PATCH /earnings/:id' do
    let(:earning) { create(:earning, user: current_user, date: Date.new(2026, 1, 10), amount: 100, platform: 'shopee') }

    it 'updates earning attributes' do
      patch earning_path(earning),
            params: {
              record:  {
                date:     '2026-01-12',
                amount:   200.50,
                platform: 'uber',
                notes:    'Ajuste manual'
              },
              context: { year: 2026, month: 1 }
            },
            as:     :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(earning.reload.amount).to eq(200.5)
      expect(earning.reload.platform).to eq('uber')
      expect(response.body).to include('action="refresh"')
    end

    it 'renders the earnings detail list after successful update' do
      patch earning_path(earning),
            params: {
              record:  { amount: 300.00, platform: 'uber' },
              context: { year: 2026, month: 1 }
            },
            as:     :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.title_month'))
      expect(response.body).not_to include(I18n.t('records.edit_view.title'))
      expect(response.body).to include('action="refresh"')
    end

    it 'handles validation errors on update' do
      patch earning_path(earning),
            params: { record: { amount: 0 }, context: { year: 2026, month: 1 } },
            as:     :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('records.edit_view.title'))
      expect(response.body).to include('bg-red-50')
    end

    it 'responds with a turbo stream refresh so only changed content updates' do
      patch earning_path(earning),
            params: { record: { amount: 200.50 }, context: { year: 2026, month: 1 } },
            as:     :turbo_stream

      expect(response.body).to include('action="refresh"')
      expect(response.body).not_to include('target="hero_profit_card"')
    end
  end

  describe 'scoping by current user' do
    it 'returns 404 when editing another user earning' do
      other_user = create(:user)
      other_earning = create(:earning, user: other_user)

      get edit_earning_path(other_earning), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when updating another user earning' do
      other_earning = create(:earning, user: create(:user), amount: 100)

      patch earning_path(other_earning), params: { record: { amount: 999 } }, as: :turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(other_earning.reload.amount).to eq(100)
    end

    it 'returns 404 when deleting another user earning' do
      other_earning = create(:earning, user: create(:user))

      delete earning_path(other_earning), as: :turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(Earning.exists?(other_earning.id)).to be(true)
    end
  end

  describe 'DELETE /earnings/:id' do
    it 'destroys the earning' do
      earning = create(:earning, user: current_user, date: Date.new(2026, 1, 10), amount: 100, platform: :shopee)

      expect {
        delete earning_path(earning),
               params: { context: { year: 2026, month: 1 } },
               as:     :turbo_stream
      }.to change(Earning, :count).by(-1)
    end

    it 're-renders the detail list and triggers morph refresh after destroy' do
      earning = create(:earning, user: current_user, date: Date.new(2026, 1, 10), amount: 100, platform: :shopee)

      delete earning_path(earning),
             params: { context: { year: 2026, month: 1 } },
             as:     :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.title_month'))
      expect(response.body).to include('action="refresh"')
      expect(response.body).not_to include('target="stats_grid"')
    end
  end
end

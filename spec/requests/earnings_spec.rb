require 'rails_helper'

RSpec.describe 'Earnings', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /earnings/new' do
    it 'redirects to /records/new?type=earning' do
      get new_earning_path

      expect(response).to redirect_to(new_record_path(type: 'earning'))
    end

    it 'preserves context params on redirect' do
      get new_earning_path, params: { context: { year: 2026 } }

      expect(response.location).to include('context%5Byear%5D=2026')
    end
  end

  describe 'POST /earnings' do
    let(:valid_params) do
      {
        earning: {
          date: '2026-01-23',
          amount: 200.00,
          platform: 'uber',
          trips_count: 2
        },
        context: { year: 2026 }
      }
    end

    it 'creates a new earning' do
      expect {
        post earnings_path, params: valid_params, as: :turbo_stream
      }.to change(Earning, :count).by(1)
    end

    it 'responds with turbo stream updating home cards' do
      post earnings_path, params: valid_params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('target="stats_grid"')
      expect(response.body).to include('target="hero_profit_card"')
      expect(response.body).to include('target="today_card"')
      expect(response.body).to include('target="recent_activity"')
      expect(response.body).to include('target="category_breakdown"')
      expect(response.body).to include('target="dashboard_filters"')
      expect(response.body).to include('target="flash"')
    end

    it 'handles validation errors by re-rendering the modal' do
      post earnings_path,
           params: { earning: { amount: 0, platform: 'uber' }, context: { year: 2026 } },
           as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('earnings.new_view.title'))
    end
  end

  describe 'GET /earnings/:id/edit' do
    it 'renders edit modal form with platform options' do
      earning = create(:earning, user: current_user, amount: 100)

      get edit_earning_path(earning), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('earnings.edit_view.title'))
      expect(response.body).to include('value="2026"')
      expect(response.body).to include('Amazon')
      expect(response.body).to include('Mercado Livre')
      expect(response.body).not_to include('Translation missing')
      expect(response.body).to include('Editar Receita')
      expect(response.body).to include('Ajuste os dados da receita')
    end
  end

  describe 'PATCH /earnings/:id' do
    let(:earning) { create(:earning, user: current_user, date: Date.new(2026, 1, 10), amount: 100, platform: 'shopee') }

    it 'updates earning attributes' do
      patch earning_path(earning),
            params: {
              earning: {
                date: '2026-01-12',
                amount: 200.50,
                platform: 'uber',
                notes: 'Ajuste manual'
              },
              context: { year: 2026, month: 1 }
            },
            as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(earning.reload.amount).to eq(200.5)
      expect(earning.reload.platform).to eq('uber')
      expect(response.body).to include('stats_grid')
    end

    it 'renders the earnings detail list after successful update' do
      patch earning_path(earning),
            params: {
              earning: { amount: 300.00, platform: 'uber' },
              context: { year: 2026, month: 1 }
            },
            as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.title'))
      expect(response.body).not_to include(I18n.t('earnings.edit_view.title'))
      expect(response.body).to include('stats_grid')
    end

    it 'handles validation errors on update' do
      patch earning_path(earning),
            params: { earning: { amount: 0 }, context: { year: 2026, month: 1 } },
            as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('earnings.edit_view.title'))
    end

    it 'refreshes home cards on update' do
      patch earning_path(earning),
            params: { earning: { amount: 200.50 }, context: { year: 2026, month: 1 } },
            as: :turbo_stream

      expect(response.body).to include('target="hero_profit_card"')
      expect(response.body).to include('target="today_card"')
      expect(response.body).to include('target="recent_activity"')
      expect(response.body).to include('target="category_breakdown"')
    end
  end

  describe 'DELETE /earnings/:id' do
    it 'destroys the earning' do
      earning = create(:earning, user: current_user, date: Date.new(2026, 1, 10), amount: 100, platform: :shopee)

      expect {
        delete earning_path(earning),
               params: { context: { year: 2026, month: 1 } },
               as: :turbo_stream
      }.to change(Earning, :count).by(-1)
    end

    it 're-renders the detail list and home cards after destroy' do
      earning = create(:earning, user: current_user, date: Date.new(2026, 1, 10), amount: 100, platform: :shopee)

      delete earning_path(earning),
             params: { context: { year: 2026, month: 1 } },
             as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.title'))
      expect(response.body).to include('target="stats_grid"')
      expect(response.body).to include('target="hero_profit_card"')
      expect(response.body).to include('target="today_card"')
      expect(response.body).to include('target="recent_activity"')
      expect(response.body).to include('target="category_breakdown"')
    end
  end
end

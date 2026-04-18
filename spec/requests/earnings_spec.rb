require 'rails_helper'

RSpec.describe "Earnings", type: :request do
  describe "GET /earnings/new" do
    it "renders the modal form" do
      get new_earning_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('earnings.new_view.title'))
    end

    it "passes context params to the form" do
      get new_earning_path, params: { context: { year: 2026 } }

      expect(response.body).to include('name="context[year]"')
      expect(response.body).to include('value="2026"')
    end
  end

  describe "POST /earnings" do
    let(:valid_params) do
      {
        earning: {
          date: '2026-01-23',
          amount: 200.00,
          platform: 'uber'
        },
        context: { year: 2026 }
      }
    end

    it "creates a new earning" do
      expect {
        post earnings_path, params: valid_params, as: :turbo_stream
      }.to change(Earning, :count).by(1)
    end

    it "responds with turbo stream to update stats grid" do
      post earnings_path, params: valid_params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('stats_grid')
      expect(response.body).to include('flash')
    end

    it "handles validation errors by re-rendering the modal" do
      post earnings_path,
           params: { earning: { amount: 0, platform: 'uber' }, context: { year: 2026 } },
           as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('earnings.new_view.title'))
    end
  end

  describe "GET /earnings/:id/edit" do
    it "renders edit modal form" do
      earning = create(:earning, amount: 100)

      get edit_earning_path(earning), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('earnings.edit_view.title'))
      expect(response.body).to include('value="2026"')
      expect(response.body).to include('Amazon')
      expect(response.body).to include('Mercado Livre')
      expect(response.body).not_to include('Translation missing')
    end
  end

  describe "PATCH /earnings/:id" do
    let(:earning) { create(:earning, date: Date.new(2026, 1, 10), amount: 100, platform: 'shopee') }

    it "updates earning and responds with turbo stream" do
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
      expect(earning.platform).to eq('uber')
      expect(response.body).to include('stats_grid')
    end

    it "renders the earnings detail list after successful update" do
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

    it "handles validation errors on update" do
      patch earning_path(earning),
            params: { earning: { amount: 0 }, context: { year: 2026, month: 1 } },
            as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('earnings.edit_view.title'))
    end
  end
end

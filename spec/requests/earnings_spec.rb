require 'rails_helper'

RSpec.describe "Earnings", type: :request do
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

    it "handles validation errors on update" do
      patch earning_path(earning),
            params: { earning: { amount: 0 }, context: { year: 2026, month: 1 } },
            as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('earnings.edit_view.title'))
    end
  end
end

require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    before do
      create(:earning, date: Date.current, amount: 500)
    end

    it "renders the dashboard successfully" do
      get root_path
      expect(response).to have_http_status(:success)

      expect(response.body.squish).to include("500,00")
    end

    it "filters by year" do
      past_year = Date.current.year - 1
      get root_path, params: { year: past_year }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("0,00")
    end
  end

  describe "GET /dashboard/earnings_detail" do
    it "renders earnings detail in modal frame" do
      trip = create(:trip)
      create(:earning, trip: trip, date: Date.new(2025, 1, 15), amount: 100.50)
      create(:earning, trip: trip, date: Date.new(2025, 1, 20), amount: 250)

      get dashboard_earnings_detail_path(year: 2025, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.title'))
      expect(response.body).to include("100,50")
      expect(response.body).to include("250,00")
      expect(response.body).to include("350,50")
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.total'))
    end

    it "shows empty state when no earnings in period" do
      get dashboard_earnings_detail_path(year: 2020, month: 1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.empty'))
    end

    it "renders annual view with monthly totals when month filter is all" do
      trip = create(:trip)
      create(:earning, trip: trip, date: Date.new(2025, 1, 15), amount: 100)
      create(:earning, trip: trip, date: Date.new(2025, 2, 10), amount: 250)
      create(:earning, trip: trip, date: Date.new(2025, 2, 20), amount: 50)

      get dashboard_earnings_detail_path(year: 2025)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.columns.month'))
      expect(response.body).to include(I18n.t('date.month_names')[1])
      expect(response.body).to include(I18n.t('date.month_names')[2])
      expect(response.body).to include("100,00")
      expect(response.body).to include("300,00")
      expect(response.body).to include("400,00")
      expect(response.body).to include(I18n.t('dashboard.earnings_detail_view.total'))
    end
  end
end

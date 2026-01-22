# spec/requests/dashboard_request_spec.rb
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
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /index" do
    before do
      create(:delivery, date: '2024-12-01', route_value: 500.0, fuel_cost: 0, maintenance_cost: 0, other_costs: 0)
    end

    it "returns success and renders the value of the gain" do
      get root_path, params: { year: 2024 }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("R$ 500,00")
    end

    it "filter data correctly by changing the year" do
      get root_path, params: { year: 2025 }

      expect(response.body).to include("R$ 0,00")
      expect(response.body).not_to include("R$ 500,00")
    end
  end
end

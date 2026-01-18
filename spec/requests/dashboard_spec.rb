# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /index" do
    before do
      create(:delivery, date: '2024-12-01', route_value: 500.0, fuel_cost: 0, maintenance_cost: 0, other_costs: 0)
    end

    it "returns success and renders the localized title and gain" do
      get root_path, params: { year: 2024 }

      expect(response).to have_http_status(:success)
      
      normalized_body = response.body.squish

      expect(normalized_body).to include(I18n.t('dashboard.index_view.title'))
      expect(normalized_body).to include(format_currency(500.0))
    end

    it "filter data correctly by changing the year" do
      get root_path, params: { year: 2025 }

      normalized_body = response.body.squish

      expect(normalized_body).to include(format_currency(0))
      expect(normalized_body).not_to include(format_currency(500.0))
    end
  end

  def format_currency(value)
    ActiveSupport::NumberHelper.number_to_currency(value).squish
  end
end

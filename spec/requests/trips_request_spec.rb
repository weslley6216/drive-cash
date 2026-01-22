require 'rails_helper'

RSpec.describe "Trips", type: :request do
  describe "GET /trips/new" do
    it "renders the modal form" do
      get new_trip_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include('Nova Entrada')
    end

    it "passes context params to the form" do
      get new_trip_path, params: { context: { year: 2023 } }

      expect(response.body).to include('value="2023"')
    end
  end

  describe "POST /trips" do
    let(:valid_params) do
      {
        trip: {
          date: Date.current,
          route_value: 100,
          fuel_cost: 20,
          platform: 'shopee'
        },
        context: { year: 2025 }
      }
    end

    it "creates trip, earnings and expenses" do
      expect {
        post trips_path, params: valid_params, as: :turbo_stream
      }.to change(Trip, :count).by(1)
       .and change(Earning, :count).by(1)
       .and change(Expense, :count).by(1)
    end

    it "responds with turbo stream to update stats" do
      post trips_path, params: valid_params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('stats_grid')
      expect(response.body).to include('flash')
    end

    it "handles validation errors" do
      invalid_params = { trip: { route_value: nil } } 
      
      post trips_path, params: invalid_params, as: :turbo_stream

      expect(response.body).to include('Nova Entrada')
    end
  end
end

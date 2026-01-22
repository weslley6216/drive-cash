require 'rails_helper'

RSpec.describe "TripEntries", type: :request do
  describe "GET /trip_entries/new" do
    it "renders the modal form" do
      get new_trip_entry_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include('Nova Entrada')
    end

    it "passes context params to the form" do
      get new_trip_entry_path, params: { context: { year: 2023 } }
      expect(response.body).to include('value="2023"')
    end
  end

  describe "POST /trip_entries" do
    let(:valid_params) do
      {
        trip_entry: {
          date: Date.current,
          route_value: 100,
          fuel_cost: 20
        },
        context: { year: 2025 }
      }
    end

    it "creates earnings and expenses" do
      expect {
        post trip_entries_path, params: valid_params, as: :turbo_stream
      }.to change(Earning, :count).by(1).and change(Expense, :count).by(1)
    end

    it "responds with turbo stream to update stats" do
      post trip_entries_path, params: valid_params, as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('stats_grid')
      expect(response.body).to include('flash')
    end

    it "handles validation errors" do
      invalid_params = { trip_entry: { route_value: nil } }
      post trip_entries_path, params: invalid_params, as: :turbo_stream

      expect(response.body).to include('Nova Entrada')
      expect(response.body).to include('não pode ficar em branco')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Deliveries", type: :request do
  describe "GET /deliveries/new" do
    it "returns success" do
      get new_delivery_path
      expect(response).to have_http_status(:success)
    end

    it "renders the new delivery form" do
      get new_delivery_path
      expect(response.body).to include('Nova Receita')
    end

    it "renders the modal frame" do
      get new_delivery_path
      expect(response.body).to include('turbo-frame')
      expect(response.body).to include('id="modal"')
    end
  end

  describe "POST /deliveries" do
    context "with valid params" do
      let(:valid_params) do
        {
          delivery: {
            date: Date.current,
            route_value: 250.0,
            fuel_cost: 60.0,
            maintenance_cost: 20.0,
            other_costs: 10.0
          }
        }
      end

      it "creates a new delivery" do
        expect {
          post deliveries_path, params: valid_params, as: :turbo_stream
        }.to change(Delivery, :count).by(1)
      end

      it "responds with turbo stream content type" do
        post deliveries_path, params: valid_params, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
      end

      it "updates stats grid on success" do
        post deliveries_path, params: valid_params, as: :turbo_stream
        expect(response.body).to include('stats_grid')
        expect(response.body).to include('turbo-stream')
      end

      it "closes modal on success" do
        post deliveries_path, params: valid_params, as: :turbo_stream
        expect(response.body).to include('target="modal"')
        expect(response.body).to include('action="update"')
      end

      it "shows success flash message" do
        post deliveries_path, params: valid_params, as: :turbo_stream
        expect(response.body).to include('Receita registrada com sucesso!')
      end

      it "sets default values for nil costs" do
        params = {
          delivery: {
            date: Date.current,
            route_value: 250.0
          }
        }

        post deliveries_path, params: params, as: :turbo_stream

        delivery = Delivery.last
        expect(delivery.fuel_cost).to eq(0)
        expect(delivery.maintenance_cost).to eq(0)
        expect(delivery.other_costs).to eq(0)
      end

      it "updates flash stream" do
        post deliveries_path, params: valid_params, as: :turbo_stream
        expect(response.body).to include('target="flash"')
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        { delivery: { date: nil, route_value: nil } }
      end

      it "does not create a delivery" do
        expect {
          post deliveries_path, params: invalid_params, as: :turbo_stream
        }.not_to change(Delivery, :count)
      end

      it "keeps modal open with errors" do
        post deliveries_path, params: invalid_params, as: :turbo_stream
        expect(response.body).to include('target="modal"')
        expect(response.body).to include('action="replace"')
      end

      it "shows error flash message" do
        post deliveries_path, params: invalid_params, as: :turbo_stream
        expect(response.body).to include('Erro ao salvar')
      end

      it "re-renders the form with errors" do
        post deliveries_path, params: invalid_params, as: :turbo_stream
        expect(response.body).to include('Nova Receita')
      end

      it "returns success status (turbo stream handles errors in view)" do
        post deliveries_path, params: invalid_params, as: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end

    context "with negative values" do
      let(:negative_params) do
        {
          delivery: {
            date: Date.current,
            route_value: -100,
            fuel_cost: -20
          }
        }
      end

      it "does not create a delivery with negative route_value" do
        expect {
          post deliveries_path, params: negative_params, as: :turbo_stream
        }.not_to change(Delivery, :count)
      end

      it "shows validation errors" do
        post deliveries_path, params: negative_params, as: :turbo_stream
        expect(response.body).to include('Erro ao salvar')
      end
    end
  end
end

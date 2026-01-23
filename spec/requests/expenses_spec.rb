require 'rails_helper'

RSpec.describe "Expenses", type: :request do
  describe "GET /expenses/new" do
    it "renders the modal form" do
      get new_expense_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('expenses.new_view.title'))
    end

    it "passes context params to the form" do
      get new_expense_path, params: { context: { year: 2026 } }

      expect(response.body).to include('name="context[year]"')
      expect(response.body).to include('value="2026"')
    end
  end

  describe "POST /expenses" do
    let(:valid_params) do
      {
        expense: {
          date: '2026-01-23',
          amount: 150.50,
          category: 'maintenance',
          vendor: 'Oficina do João',
          description: 'Troca de óleo'
        },
        context: { year: 2026 }
      }
    end

    it "creates a new expense and associates it with a trip" do
      expect {
        post expenses_path, params: valid_params, as: :turbo_stream
      }.to change(Expense, :count).by(1)
       .and change(Trip, :count).by(1)
    end

    it "responds with turbo stream to update stats grid" do
      post expenses_path, params: valid_params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('stats_grid')
      expect(response.body).to include('flash')
    end

    it "handles validation errors by re-rendering the modal" do
      invalid_params = { expense: { amount: 0, category: 'fuel' } }

      post expenses_path, params: invalid_params, as: :turbo_stream

      expect(response.body).to include(I18n.t('expenses.new_view.title'))
    end

    it "updates the stats using the correct context year" do
      expect(Dashboard::StatsService).to receive(:new).with(year: 2026).and_call_original

      post expenses_path, params: valid_params, as: :turbo_stream
    end
  end
end

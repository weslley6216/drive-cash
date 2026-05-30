require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
  describe 'GET /expenses/new' do
    it 'renders the modal form' do
      get new_expense_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('expenses.new_view.title'))
      expect(response.body).to include('installment[repeat]')
    end

    it 'passes context params to the form' do
      get new_expense_path, params: { context: { year: 2026 } }

      expect(response.body).to include('name="context[year]"')
      expect(response.body).to include('value="2026"')
    end
  end

  describe 'POST /expenses' do
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

    it 'creates a new expense' do
      expect {
        post expenses_path, params: valid_params, as: :turbo_stream
      }.to change(Expense, :count).by(1)
    end

    it 'creates multiple installments when repeat is enabled' do
      params = {
        expense: {
          date: '2026-01-10',
          amount: 300.00,
          category: 'maintenance',
          vendor: 'Oficina',
          description: 'Pneus'
        },
        installment: {
          repeat: '1',
          period: 'monthly',
          repetitions: '3'
        },
        context: { year: 2026 }
      }

      expect {
        post expenses_path, params: params, as: :turbo_stream
      }.to change(Expense, :count).by(3)

      expect(Expense.order(:installment_number).pluck(:paid)).to all(eq(false))
      expect(Expense.distinct.pluck(:installment_series_id).compact.size).to eq(1)
    end

    it 'responds with turbo stream updating the stats grid' do
      post expenses_path, params: valid_params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('stats_grid')
      expect(response.body).to include('flash')
    end

    it 'handles validation errors by re-rendering the modal' do
      post expenses_path,
           params: { expense: { amount: 0, category: 'fuel' } },
           as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('expenses.new_view.title'))
    end

    it 're-renders new expense when installment parameters are invalid' do
      params = {
        expense: {
          date: '2026-01-10',
          amount: 300.00,
          category: 'maintenance',
          vendor: 'Oficina',
          description: 'Pneus'
        },
        installment: {
          repeat: '1',
          period: 'monthly',
          repetitions: '1'
        },
        context: { year: 2026 }
      }

      post expenses_path, params: params, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('expenses.new_view.title'))
    end
  end

  describe 'GET /expenses/:id/edit' do
    it 'renders edit modal form' do
      expense = create(:expense, category: 'fuel', amount: 80)

      get edit_expense_path(expense), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('expenses.edit_view.title'))
      expect(response.body).to include('value="2026"')
      expect(response.body).to include('expense[paid]')
    end
  end

  describe 'PATCH /expenses/:id' do
    let(:expense) { create(:expense, date: Date.new(2026, 1, 10), amount: 80, category: 'fuel') }

    it 'updates expense attributes' do
      patch expense_path(expense),
            params: {
              expense: {
                date: '2026-01-11',
                amount: 120.75,
                category: 'maintenance',
                vendor: 'Oficina Azul',
                description: 'Revisao'
              },
              context: { year: 2026, month: 1 }
            },
            as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(expense.reload.amount).to eq(120.75)
      expect(expense.reload.category).to eq('maintenance')
      expect(expense.reload.vendor).to eq('Oficina Azul')
      expect(response.body).to include('stats_grid')
    end

    it 'renders the expenses detail list after successful update' do
      patch expense_path(expense),
            params: {
              expense: { amount: 200.00, category: 'maintenance' },
              context: { year: 2026, month: 1 }
            },
            as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title'))
      expect(response.body).not_to include(I18n.t('expenses.edit_view.title'))
      expect(response.body).to include('stats_grid')
    end

    it 'handles validation errors on update' do
      patch expense_path(expense),
            params: { expense: { amount: 0 }, context: { year: 2026, month: 1 } },
            as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('expenses.edit_view.title'))
    end
  end

  describe 'DELETE /expenses/:id' do
    it 'destroys the expense' do
      expense = create(:expense, date: Date.new(2026, 1, 10), amount: 100, category: :fuel)

      expect {
        delete expense_path(expense),
               params: { context: { year: 2026, month: 1 } },
               as: :turbo_stream
      }.to change(Expense, :count).by(-1)
    end

    it 're-renders the detail list after destroy' do
      expense = create(:expense, date: Date.new(2026, 1, 10), amount: 100, category: :fuel)

      delete expense_path(expense),
             params: { context: { year: 2026, month: 1 } },
             as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title'))
      expect(response.body).to include('stats_grid')
    end
  end
end

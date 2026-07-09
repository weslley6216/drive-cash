require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /expenses/new' do
    it 'redirects to /records/new?type=expense' do
      get new_expense_path

      expect(response).to redirect_to(new_record_path(type: 'expense'))
    end

    it 'preserves context params on redirect' do
      get new_expense_path, params: { context: { year: 2026 } }

      expect(response.location).to include('context%5Byear%5D=2026')
    end
  end

  describe 'POST /expenses' do
    let(:valid_params) do
      {
        expense: {
          date:        '2026-01-23',
          amount:      150.50,
          category:    'maintenance',
          vendor:      'Oficina do João',
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
        expense:     {
          date:        '2026-01-10',
          amount:      300.00,
          category:    'maintenance',
          vendor:      'Oficina',
          description: 'Pneus'
        },
        installment: {
          repeat:      '1',
          period:      'monthly',
          repetitions: '3'
        },
        context:     { year: 2026 }
      }

      expect {
        post expenses_path, params: params, as: :turbo_stream
      }.to change(Expense, :count).by(3)

      expect(Expense.order(:installment_number).pluck(:paid)).to all(eq(false))
      expect(Expense.distinct.pluck(:installment_series_id).compact.size).to eq(1)
    end

    it 'responds with a turbo stream refresh so only changed content updates' do
      post expenses_path, params: valid_params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('action="refresh"')
      expect(response.body).not_to include('target="stats_grid"')
    end

    it 'handles validation errors by re-rendering the modal' do
      post expenses_path,
           params: { expense: { amount: 0, category: 'fuel' } },
           as:     :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('expenses.new_view.title'))
    end

    it 're-renders the refueling extension visible when the failed expense is fuel' do
      post expenses_path,
           params: { expense: { amount: 0, category: 'fuel' } },
           as:     :turbo_stream

      expect(response.body).to include('data-refueling-fields-target="extension"')
      expect(response.body).to include(I18n.t('expenses.refueling_extension.heading'))
      expect(response.body).not_to include('class="mt-2 hidden" data-refueling-fields-target="extension"')
    end

    it 're-renders the refueling extension hidden when the failed expense is not fuel' do
      post expenses_path,
           params: { expense: { amount: 0, category: 'meals' } },
           as:     :turbo_stream

      expect(response.body).to include('class="mt-2 hidden" data-refueling-fields-target="extension"')
    end

    it 're-renders new expense when installment parameters are invalid' do
      params = {
        expense:     {
          date:        '2026-01-10',
          amount:      300.00,
          category:    'maintenance',
          vendor:      'Oficina',
          description: 'Pneus'
        },
        installment: {
          repeat:      '1',
          period:      'monthly',
          repetitions: '1'
        },
        context:     { year: 2026 }
      }

      post expenses_path, params: params, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('expenses.new_view.title'))
    end
  end

  describe 'GET /expenses/:id/edit' do
    it 'renders edit modal form' do
      expense = create(:expense, user: current_user, category: 'fuel', amount: 80)

      get edit_expense_path(expense), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('expenses.edit_view.title'))
      expect(response.body).to include('value="2026"')
      expect(response.body).to include('expense[paid]')
    end

    it 'does not render the refueling extension when editing' do
      expense = create(:expense, user: current_user, category: 'fuel', amount: 80)

      get edit_expense_path(expense)

      expect(response.body).not_to include(I18n.t('expenses.refueling_extension.heading'))
    end

    it 'preselects the expense category' do
      expense = create(:expense, user: current_user, category: 'maintenance', amount: 80)

      get edit_expense_path(expense)

      expect(response.body).to include('selected="selected" value="maintenance"')
    end
  end

  describe 'PATCH /expenses/:id' do
    let(:expense) { create(:expense, user: current_user, date: Date.new(2026, 1, 10), amount: 80, category: 'fuel') }

    it 'updates expense attributes' do
      patch expense_path(expense),
            params: {
              expense: {
                date:        '2026-01-11',
                amount:      120.75,
                category:    'maintenance',
                vendor:      'Oficina Azul',
                description: 'Revisao'
              },
              context: { year: 2026, month: 1 }
            },
            as:     :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(expense.reload.amount).to eq(120.75)
      expect(expense.reload.category).to eq('maintenance')
      expect(expense.reload.vendor).to eq('Oficina Azul')
      expect(response.body).to include('action="refresh"')
    end

    it 'renders the expenses detail list after successful update' do
      patch expense_path(expense),
            params: {
              expense: { amount: 200.00, category: 'maintenance' },
              context: { year: 2026, month: 1 }
            },
            as:     :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title'))
      expect(response.body).not_to include(I18n.t('expenses.edit_view.title'))
      expect(response.body).to include('action="refresh"')
    end

    it 'handles validation errors on update' do
      patch expense_path(expense),
            params: { expense: { amount: 0 }, context: { year: 2026, month: 1 } },
            as:     :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('expenses.edit_view.title'))
    end

    it 'responds with a turbo stream refresh so only changed content updates' do
      patch expense_path(expense),
            params: { expense: { amount: 120.75 }, context: { year: 2026, month: 1 } },
            as:     :turbo_stream

      expect(response.body).to include('action="refresh"')
      expect(response.body).not_to include('target="hero_profit_card"')
    end
  end

  describe 'scoping by current user' do
    it 'returns 404 when editing another user expense' do
      other_user = create(:user)
      other_expense = create(:expense, user: other_user)

      get edit_expense_path(other_expense), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:not_found)
    end

    it 'creates expenses associated to current user' do
      post expenses_path,
           params: {
             expense: { date: '2026-01-23', amount: 150.50, category: 'maintenance', vendor: 'Oficina' },
             context: { year: 2026 }
           },
           as:     :turbo_stream

      expect(Expense.last.user).to eq(current_user)
    end
  end

  describe 'POST /expenses with fuel category and refueling params' do
    let(:vehicle) { create(:vehicle, user: current_user) }

    before { vehicle }

    it 'creates a Refueling linked to the expense' do
      post expenses_path, params: {
        expense:   { date: Date.current.to_s, amount: '180,50', category: 'fuel', vendor: 'Posto Orense' },
        refueling: { liters: '32,5', odometer_km: '48230', full_tank: '1' }
      }, as: :turbo_stream

      expect(Refueling.count).to eq(1)
      expect(Refueling.last.expense).to eq(Expense.last)
      expect(Refueling.last.odometer_km).to eq(48_230)
    end

    it 'creates expense without refueling when fields are blank' do
      post expenses_path, params: {
        expense:   { date: Date.current.to_s, amount: '180,50', category: 'fuel' },
        refueling: { liters: '', odometer_km: '' }
      }, as: :turbo_stream

      expect(Expense.count).to eq(1)
      expect(Refueling.count).to eq(0)
    end

    it 'does not create refueling when category is not fuel' do
      post expenses_path, params: {
        expense:   { date: Date.current.to_s, amount: '50,00', category: 'meals' },
        refueling: { liters: '32,5', odometer_km: '48230' }
      }, as: :turbo_stream

      expect(Refueling.count).to eq(0)
    end

    it 'rolls back the expense and refueling when the refueling data is invalid' do
      post expenses_path, params: {
        expense:   { date: Date.current.to_s, amount: '180,50', category: 'fuel', vendor: 'Posto' },
        refueling: { liters: '0', odometer_km: '48230', full_tank: '1' }
      }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(Expense.count).to eq(0)
      expect(Refueling.count).to eq(0)
    end
  end

  describe 'DELETE /expenses/:id' do
    it 'destroys the expense' do
      expense = create(:expense, user: current_user, date: Date.new(2026, 1, 10), amount: 100, category: :fuel)

      expect {
        delete expense_path(expense),
               params: { context: { year: 2026, month: 1 } },
               as:     :turbo_stream
      }.to change(Expense, :count).by(-1)
    end

    it 're-renders the detail list and triggers morph refresh after destroy' do
      expense = create(:expense, user: current_user, date: Date.new(2026, 1, 10), amount: 100, category: :fuel)

      delete expense_path(expense),
             params: { context: { year: 2026, month: 1 } },
             as:     :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title'))
      expect(response.body).to include('action="refresh"')
      expect(response.body).not_to include('target="stats_grid"')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'retired expense routes' do
    it 'no longer serves the old new expense form' do
      get '/expenses/new'

      expect(response).to have_http_status(:not_found)
    end

    it 'no longer creates expenses outside the records form' do
      expect {
        post '/expenses', params: { expense: { date: '2026-01-23', amount: 150.5, category: 'maintenance' } }, as: :turbo_stream
      }.not_to change(Expense, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /expenses/:id/edit' do
    it 'renders the new record form prefilled with the expense theme, the paid state and no recurrence' do
      expense = create(:expense, user: current_user, date: Date.new(2026, 1, 10), amount: 80, category: 'maintenance', vendor: 'Oficina Azul', paid: false)

      get edit_expense_path(expense), params: { context: { year: 2026, month: 1 } }

      expect(response).to have_http_status(:success)
      expect(response.body).to include('turbo-frame id="modal"')
      expect(response.body).to include(I18n.t('records.edit_view.title'))
      expect(response.body).to include('data-record-form-type-value="expense"')
      expect(response.body).to include(%(action="#{expense_path(expense)}"))
      expect(response.body).to include('value="maintenance" checked')
      expect(response.body).to include('value="Oficina Azul"')
      expect(response.body).to include('name="record[paid]" value="1" class="peer sr-only"')
      expect(response.body).to include('value="2026"')
      expect(response.body).to include(I18n.t('records.new_view.save_expense'))
      expect(response.body).not_to include('installment[repeat]')
      expect(response.body).not_to include('data-record-form-target="earningToggle"')
    end

    it 'shows the paid toggle on for a paid expense' do
      expense = create(:expense, user: current_user, category: 'fuel', paid: true)

      get edit_expense_path(expense)

      expect(response.body).to include('name="record[paid]" value="1" checked')
    end

    it 'offers to delete the expense returning to the period it came from' do
      expense = create(:expense, user: current_user, date: Date.new(2026, 1, 10))

      get edit_expense_path(expense), params: { context: { year: 2026, month: 1 } }

      expect(response.body).to include(I18n.t('records.edit_view.delete'))
      expect(response.body).to include(%(action="#{expense_path(expense, context: { year: '2026', month: '1' })}"))
      expect(response.body).to include('name="_method" value="delete"')
    end
  end

  describe 'PATCH /expenses/:id' do
    let(:expense) { create(:expense, user: current_user, date: Date.new(2026, 1, 10), amount: 80, category: 'fuel') }

    it 'updates expense attributes' do
      patch expense_path(expense),
            params: {
              record:  {
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

    it 'marks the expense as unpaid from the paid toggle' do
      patch expense_path(expense),
            params: { record: { paid: '0' }, context: { year: 2026, month: 1 } },
            as:     :turbo_stream

      expect(expense.reload.paid).to be(false)
    end

    it 'renders the expenses detail list after successful update' do
      patch expense_path(expense),
            params: {
              record:  { amount: 200.00, category: 'maintenance' },
              context: { year: 2026, month: 1 }
            },
            as:     :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title_month'))
      expect(response.body).not_to include(I18n.t('records.edit_view.title'))
      expect(response.body).to include('action="refresh"')
    end

    it 'handles validation errors on update' do
      patch expense_path(expense),
            params: { record: { amount: 0 }, context: { year: 2026, month: 1 } },
            as:     :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('records.edit_view.title'))
      expect(response.body).to include('bg-red-50')
    end

    it 'responds with a turbo stream refresh so only changed content updates' do
      patch expense_path(expense),
            params: { record: { amount: 120.75 }, context: { year: 2026, month: 1 } },
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

    it 'returns 404 when updating another user expense' do
      other_expense = create(:expense, user: create(:user), amount: 80)

      patch expense_path(other_expense), params: { record: { amount: 999 } }, as: :turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(other_expense.reload.amount).to eq(80)
    end

    it 'returns 404 when deleting another user expense' do
      other_expense = create(:expense, user: create(:user))

      delete expense_path(other_expense), as: :turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(Expense.exists?(other_expense.id)).to be(true)
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
      expect(response.body).to include(I18n.t('dashboard.expenses_detail_view.title_month'))
      expect(response.body).to include('action="refresh"')
      expect(response.body).not_to include('target="stats_grid"')
    end
  end
end

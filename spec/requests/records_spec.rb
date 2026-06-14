require 'rails_helper'

RSpec.describe 'Records', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /records/new' do
    it 'returns 200 with title' do
      get new_record_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('records.new_view.title'))
    end

    it 'defaults type to earning' do
      get new_record_path

      expect(response.body).to include('data-record-form-type-value="earning"')
    end

    it 'accepts type=expense' do
      get new_record_path, params: { type: 'expense' }

      expect(response.body).to include('data-record-form-type-value="expense"')
    end

    it 'renders the type toggle' do
      get new_record_path

      expect(response.body).to include(I18n.t('records.new_view.type_toggle.earning'))
      expect(response.body).to include(I18n.t('records.new_view.type_toggle.expense'))
    end

    it 'renders the platform picker when type is earning' do
      get new_record_path, params: { type: 'earning' }

      expect(response.body).to include(I18n.t('records.new_view.platform_label'))
    end

    it 'renders the category picker when type is expense' do
      get new_record_path, params: { type: 'expense' }

      expect(response.body).to include(I18n.t('records.new_view.category_label'))
    end

    it 'submits to records_path with hidden type field' do
      get new_record_path

      expect(response.body).to include('action="/records"')
      expect(response.body).to match(/<input[^>]*name="type"/)
    end

    it 'renders the sticky CTA' do
      get new_record_path, params: { type: 'expense' }

      expect(response.body).to include(I18n.t('records.new_view.save_expense'))
    end

    it 'renders an editable date input' do
      get new_record_path

      expect(response.body).to include('type="date"')
      expect(response.body).to include('name="record[date]"')
    end

    it 'renders recurring section for expense type' do
      get new_record_path, params: { type: 'expense' }

      expect(response.body).to include(I18n.t('records.new_view.recurring_toggle.title'))
    end

    it 'renders earningFields Stimulus target for JS toggling' do
      get new_record_path, params: { type: 'earning' }

      expect(response.body).to include('data-record-form-target="earningFields"')
      expect(response.body).to include('data-record-form-target="expenseFields"')
    end

    it 'applies sm:grid-cols-2 two-column desktop layout for amount and date' do
      get new_record_path

      expect(response.body).to include('sm:grid-cols-2')
    end
  end

  describe 'POST /records' do
    context 'when type is earning' do
      let(:valid_params) do
        {
          type:   'earning',
          record: { date: '2026-05-22', amount: '245.00', platform: 'uber', notes: 'x', trips_count: 7 }
        }
      end

      it 'creates an Earning' do
        expect {
          post records_path, params: valid_params
        }.to change(Earning, :count).by(1)
      end

      it 'redirects to root with notice' do
        post records_path, params: valid_params

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('records.create.success'))
      end
    end

    context 'when type is earning and invalid' do
      it 're-renders the new view with errors' do
        params = { type: 'earning', record: { amount: '0', platform: 'uber', date: '2026-05-22', trips_count: 1 } }

        post records_path, params: params

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Valor')
      end
    end

    context 'when type is expense' do
      let(:valid_params) do
        {
          type:   'expense',
          record: { date: '2026-05-22', amount: '60.00', category: 'fuel', vendor: 'Posto Orense', description: '', paid: '1' }
        }
      end

      it 'creates an Expense via Expenses::Creator' do
        expect {
          post records_path, params: valid_params
        }.to change(Expense, :count).by(1)
      end

      it 'persists paid=false when toggle is off' do
        params = valid_params.deep_merge(record: { paid: '0' })

        post records_path, params: params

        expect(Expense.last.paid).to eq(false)
      end

      it 'redirects to root with notice' do
        post records_path, params: valid_params

        expect(response).to redirect_to(root_path)
      end
    end

    context 'when type is expense and invalid' do
      it 're-renders the new view with errors' do
        params = { type: 'expense', record: { amount: '', category: 'fuel', date: '2026-05-22' } }

        post records_path, params: params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when type is unknown' do
      it 'returns 400 bad request' do
        post records_path, params: { type: 'unknown', record: {} }

        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'data isolation on record creation' do
      let(:other_user) { create(:user) }

      it 'associates the created earning with the current user' do
        params = { type: 'earning', record: { date: Date.current.to_s, amount: '100', platform: 'uber', trips_count: '1' } }

        post records_path, params: params

        expect(Earning.unscoped.last.user).to eq(current_user)
      end

      it 'associates the created expense with the current user' do
        params = { type: 'expense', record: { date: Date.current.to_s, amount: '50', category: 'fuel' } }

        post records_path, params: params

        expect(Expense.unscoped.last.user).to eq(current_user)
      end

      it 'does not show another user earnings on the dashboard' do
        create(:earning, user: other_user, amount: 9_555.00, date: Date.current)

        get root_path

        expect(response.body).not_to include('9.555')
      end
    end
  end
end

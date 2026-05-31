require 'rails_helper'

RSpec.describe 'Records', type: :request do
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

    it 'renders save button in top bar' do
      get new_record_path

      expect(response.body).to include('data-record-form-target="topSave"')
    end

    it 'renders recurring section for expense type' do
      get new_record_path, params: { type: 'expense' }

      expect(response.body).to include(I18n.t('records.new_view.recurring_toggle.title'))
    end

    it 'applies sm:grid-cols-2 desktop layout' do
      get new_record_path

      expect(response.body).to include('sm:grid')
    end
  end
end

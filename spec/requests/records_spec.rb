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
  end
end

require 'rails_helper'

RSpec.describe 'History', type: :request do
  describe 'GET /history' do
    it 'returns 200' do
      get history_path

      expect(response).to have_http_status(:ok)
    end
  end
end

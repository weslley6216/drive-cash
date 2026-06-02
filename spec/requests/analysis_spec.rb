require 'rails_helper'

RSpec.describe 'Analysis', type: :request do
  describe 'GET /analysis' do
    it 'responds 200' do
      get analysis_path

      expect(response).to have_http_status(:success)
    end

    it 'renders the page title' do
      get analysis_path

      expect(response.body).to include(I18n.t('analysis.show_view.title'))
    end
  end
end

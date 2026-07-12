require 'rails_helper'

RSpec.describe 'Coming soon placeholder', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  describe 'GET /coming_soon' do
    it 'responds 200 with em breve content' do
      get '/coming_soon'

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t('application.coming_soon_view.title'))
      expect(response.body).to include(I18n.t('application.coming_soon_view.back'))
      expect(response.body).to include('href="/"')
    end

    it 'renders bottom nav so users can navigate away' do
      get '/coming_soon'

      expect(response.body).to include('fixed bottom-0 left-0 right-0')
      expect(response.body).to include(I18n.t('bottom_nav_component.tabs.home'))
    end
  end
end

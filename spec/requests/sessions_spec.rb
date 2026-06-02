require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { create(:user) }

  describe 'GET /session/new' do
    it 'renders the login page' do
      get new_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('sessions.new_view.title'))
      expect(response.body).to include(I18n.t('sessions.new_view.email'))
      expect(response.body).to include(I18n.t('sessions.new_view.password'))
    end
  end

  describe 'POST /session' do
    it 'signs in with valid credentials and redirects to root' do
      post session_path, params: { email_address: user.email_address, password: 'password123' }

      expect(response).to redirect_to(root_path)
    end

    it 'redirects to new_session_path with alert when credentials are invalid' do
      post session_path, params: { email_address: user.email_address, password: 'wrong' }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to eq(I18n.t('sessions.invalid_credentials'))
    end
  end

  describe 'DELETE /session' do
    before { post session_path, params: { email_address: user.email_address, password: 'password123' } }

    it 'signs out the user and redirects to login' do
      delete session_path

      expect(response).to redirect_to(new_session_path)
    end
  end
end

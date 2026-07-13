require 'rails_helper'

RSpec.describe 'Reauthentications', type: :request do
  let(:user) { create(:user) }

  describe 'GET /reauthentication/new' do
    it 'redirects to login when unauthenticated' do
      get new_reauthentication_path

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the challenge with a password field posting to the reauthentication path' do
        get new_reauthentication_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('reauthentications.new_view.heading'))
        expect(response.body).to include('name="password"')
        expect(response.body).to include('action="/reauthentication"')
      end
    end
  end

  describe 'POST /reauthentication' do
    before { login_as(user) }

    it 'elevates the session and redirects to the profile when the password is correct' do
      post reauthentication_path, params: { password: 'password123' }

      expect(response).to redirect_to(edit_profile_path)
      expect(user.sessions.last.reload.reauthenticated?).to be(true)
    end

    it 're-renders with an error and does not elevate when the password is wrong' do
      post reauthentication_path, params: { password: 'wrong' }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('reauthentications.new_view.error'))
      expect(user.sessions.last.reload.reauthenticated?).to be(false)
    end

    it 'redirects with a rate limit alert after too many attempts and renders it on the challenge' do
      11.times { post reauthentication_path, params: { password: 'wrong' } }

      expect(response).to redirect_to(new_reauthentication_path)
      expect(flash[:alert]).to include(I18n.t('reauthentications.rate_limit'))

      follow_redirect!
      expect(response.body).to include(I18n.t('reauthentications.rate_limit'))
    end
  end
end

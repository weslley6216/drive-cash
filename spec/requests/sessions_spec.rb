require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { create(:user) }

  describe 'GET /session/new' do
    it 'renders the redesigned login view with BrandMark and welcome headline' do
      get new_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('sessions.new_view.welcome'))
      expect(response.body).to include(I18n.t('sessions.new_view.welcome_subtitle'))
      expect(response.body).to include(I18n.t('sessions.new_view.email_label'))
      expect(response.body).to include(I18n.t('sessions.new_view.password_label'))
      expect(response.body).to include('viewBox="0 0 100 100"')
    end

    it 'renders required attributes on email and password inputs' do
      get new_session_path

      expect(response.body).to include('name="email_address"')
      expect(response.body).to include('name="password"')
      expect(response.body).to include('required')
    end

    it 'wires the password toggle stimulus controller' do
      get new_session_path

      expect(response.body).to include('data-controller="password-toggle"')
      expect(response.body).to include('data-action="click->password-toggle#toggle"')
    end

    it 'renders the remember_me hidden and checkbox inputs' do
      get new_session_path

      expect(response.body).to match(/<input[^>]+type="hidden"[^>]+name="remember_me"[^>]+value="0"/)
      expect(response.body).to match(/<input[^>]+type="checkbox"[^>]+name="remember_me"[^>]+value="1"/)
    end

    it 'links the forgot password button to new_password_path' do
      get new_session_path

      expect(response.body).to include("href=\"#{new_password_path}\"")
    end

    it 'links the create account button to new_registration_path' do
      get new_session_path

      expect(response.body).to include("href=\"#{new_registration_path}\"")
    end

    it 'renders the desktop hero panel with brand headline and copyright' do
      get new_session_path

      expect(response.body).to include('lg:flex')
      expect(response.body).to include(I18n.t('sessions.new_view.brand_headline_line1'))
      expect(response.body).to include(I18n.t('sessions.new_view.copyright'))
    end

    it 'renders the Google sign-in button posting to /auth/google_oauth2' do
      get new_session_path

      expect(response.body).to include(I18n.t('sessions.new_view.google'))
      expect(response.body).to include('action="/auth/google_oauth2"')
    end

    it 'redirects to root when the user is already authenticated' do
      login_as(user)

      get new_session_path

      expect(response).to redirect_to(root_path)
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

    it 'redirects to new_session_path with the same alert when email is not registered' do
      post session_path, params: { email_address: 'unknown@gmail.com', password: 'password123' }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to eq(I18n.t('sessions.invalid_credentials'))
    end

    it 'renders the alert banner inline after following the redirect' do
      post session_path, params: { email_address: user.email_address, password: 'wrong' }
      follow_redirect!

      expect(response.body).to include(I18n.t('sessions.invalid_credentials'))
    end

    context 'with remember_me' do
      it 'sets a permanent session cookie when remember_me is "1"' do
        post session_path, params: { email_address: user.email_address, password: 'password123', remember_me: '1' }

        cookie_header = Array(response.headers['Set-Cookie']).join("\n")
        expect(cookie_header).to include('session_id')
        expect(cookie_header).to include('expires=')
      end

      it 'sets a non-permanent session cookie when remember_me is "0"' do
        post session_path, params: { email_address: user.email_address, password: 'password123', remember_me: '0' }

        cookie_header = Array(response.headers['Set-Cookie']).join("\n")
        expect(cookie_header).to include('session_id')
        expect(cookie_header).not_to include('expires=')
      end
    end
  end

  describe 'rate limiting on POST /session' do
    it 'redirects with rate limit alert after too many attempts' do
      11.times { post session_path, params: { email_address: user.email_address, password: 'wrong' } }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to include(I18n.t('sessions.rate_limit'))
    end
  end

  describe 'DELETE /session' do
    before { login_as(user) }

    it 'signs out the user and redirects to login' do
      delete session_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'GET /auth/google_oauth2/callback' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid:      'oauth-uid-123',
        info:     { email: 'driver-oauth@gmail.com', name: 'Driver OAuth' }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
      Rails.application.env_config['omniauth.auth'] = auth_hash
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    it 'creates a new user when uid does not exist and redirects to root' do
      expect { get '/auth/google_oauth2/callback' }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it 'links provider and uid to an existing user with matching email' do
      existing = create(:user, email_address: 'driver-oauth@gmail.com')

      get '/auth/google_oauth2/callback'

      expect(existing.reload.provider).to eq('google_oauth2')
      expect(existing.uid).to eq('oauth-uid-123')
      expect(response).to redirect_to(root_path)
    end

    it 'reuses the existing user when uid already exists' do
      User.find_or_create_from_oauth(auth_hash)

      expect { get '/auth/google_oauth2/callback' }.not_to change(User, :count)
    end

    it 'redirects to oauth_failure when persistence raises RecordInvalid' do
      allow(User).to receive(:find_or_create_from_oauth).and_raise(
        ActiveRecord::RecordInvalid.new(User.new)
      )

      get '/auth/google_oauth2/callback'

      expect(response).to redirect_to('/auth/failure')
    end
  end

  describe 'GET /auth/failure' do
    it 'redirects to login with oauth_failure alert' do
      get '/auth/failure'

      expect(response).to redirect_to(new_session_path)
      expect(flash[:alert]).to eq(I18n.t('sessions.oauth_failure'))
    end
  end
end

require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  let(:user) { create(:user) }

  describe 'GET /passwords/new' do
    it 'renders the request form with the back link and without the brand mark' do
      get new_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('passwords.new_view.heading'))
      expect(response.body).to include(I18n.t('passwords.new_view.subtitle'))
      expect(response.body).to include(I18n.t('auth.back_to_login_component.label'))
      expect(response.body).to include(I18n.t('passwords.new_view.submit'))
    end
  end

  describe 'POST /passwords' do
    it 'enqueues the reset email when the address belongs to a user' do
      expect {
        post passwords_path, params: { email_address: user.email_address }
      }.to have_enqueued_mail(PasswordsMailer, :reset).with(user)
    end

    it 'does not enqueue an email when the address is unknown' do
      expect {
        post passwords_path, params: { email_address: 'unknown@gmail.com' }
      }.not_to have_enqueued_mail(PasswordsMailer, :reset)
    end

    it 'renders the sent screen with the typed address whether or not the account exists' do
      post passwords_path, params: { email_address: 'unknown@gmail.com' }
      unknown_response = response.body

      post passwords_path, params: { email_address: user.email_address }

      expect(response).to have_http_status(:ok)
      expect(unknown_response).to include(I18n.t('passwords.sent_view.heading'))
      expect(unknown_response).to include('unknown@gmail.com')
      expect(response.body).to include(I18n.t('passwords.sent_view.heading'))
      expect(response.body).to include(user.email_address)
    end

    it 'offers a resend form posting the same address back and a link to the sign in screen' do
      post passwords_path, params: { email_address: user.email_address }

      expect(response.body).to match(%r{<form[^>]*action="/passwords"})
      expect(response.body).to match(/<input[^>]*type="hidden"[^>]*name="email_address"[^>]*value="#{Regexp.escape(user.email_address)}"/)
      expect(response.body).to include(I18n.t('passwords.sent_view.resend'))
      expect(response.body).to include("href=\"#{new_session_path}\"")
    end

    it 'redirects back to the request form with an alert after too many requests and shows it there' do
      11.times { post passwords_path, params: { email_address: 'unknown@gmail.com' } }

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to eq(I18n.t('passwords.rate_limit'))

      follow_redirect!
      expect(response.body).to include(I18n.t('passwords.rate_limit'))
    end
  end

  describe 'GET /passwords/:token/edit' do
    it 'renders the reset form with BrandMark for a valid token' do
      token = user.password_reset_token

      get edit_password_path(token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('passwords.edit_view.title'))
      expect(response.body).to include('viewBox="0 0 100 100"')
    end

    it 'redirects with alert when the token is malformed' do
      get edit_password_path('invalid-token')

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to eq(I18n.t('passwords.not_found'))
    end

    it 'redirects with alert when the token is expired' do
      token = user.password_reset_token

      travel_to 16.minutes.from_now do
        get edit_password_path(token)

        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq(I18n.t('passwords.not_found'))
      end
    end
  end

  describe 'PATCH /passwords/:token' do
    it 'updates the password, invalidates the token and redirects to login' do
      token = user.password_reset_token

      patch password_path(token), params: { password: 'newpassword', password_confirmation: 'newpassword' }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:notice]).to eq(I18n.t('passwords.updated'))
      expect(User.authenticate_by(email_address: user.email_address, password: 'newpassword')).to eq(user)

      get edit_password_path(token)

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to eq(I18n.t('passwords.not_found'))
    end

    it 're-renders the edit form when confirmation mismatches' do
      token = user.password_reset_token

      patch password_path(token), params: { password: 'newpassword', password_confirmation: 'mismatch' }

      expect(response).to redirect_to(edit_password_path(token))
      expect(flash[:alert]).to be_present
    end

    it 'signs out every existing session after the reset' do
      user.sessions.create!(user_agent: 'device', ip_address: '1.1.1.1')
      token = user.password_reset_token

      patch password_path(token), params: { password: 'newpassword', password_confirmation: 'newpassword' }

      expect(user.sessions.reload).to be_empty
    end
  end
end

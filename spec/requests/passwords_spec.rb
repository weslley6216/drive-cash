require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  let(:user) { create(:user) }

  describe 'GET /passwords/new' do
    it 'renders the password reset request form' do
      get new_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('passwords.new_view.title'))
    end
  end

  describe 'POST /passwords' do
    it 'always redirects to login (silent on unknown email)' do
      post passwords_path, params: { email_address: 'unknown@drivecash.test' }

      expect(response).to redirect_to(new_session_path)
    end

    it 'redirects to login when email exists' do
      post passwords_path, params: { email_address: user.email_address }

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'GET /passwords/:token/edit' do
    it 'renders the reset form for a valid token' do
      token = user.password_reset_token

      get edit_password_path(token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('passwords.edit_view.title'))
    end

    it 'redirects with alert when token is invalid' do
      get edit_password_path('invalid-token')

      expect(response).to redirect_to(new_password_path)
    end
  end

  describe 'PATCH /passwords/:token' do
    it 'updates password and redirects to login' do
      token = user.password_reset_token

      patch password_path(token), params: { password: 'newpassword', password_confirmation: 'newpassword' }

      expect(response).to redirect_to(new_session_path)
    end

    it 're-renders the edit form when confirmation mismatches' do
      token = user.password_reset_token

      patch password_path(token), params: { password: 'newpassword', password_confirmation: 'mismatch' }

      expect(response).to redirect_to(edit_password_path(token))
    end
  end
end

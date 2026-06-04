require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  let(:user) { create(:user) }

  describe 'GET /passwords/new' do
    it 'renders the password reset request form with BrandMark' do
      get new_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('passwords.new_view.title'))
      expect(response.body).to include('viewBox="0 0 100 100"')
      expect(response.body).to include(I18n.t('brand_mark_component.title'))
    end
  end

  describe 'POST /passwords' do
    before { ActionMailer::Base.deliveries.clear }

    it 'sends a reset email when the address belongs to a user' do
      expect {
        post passwords_path, params: { email_address: user.email_address }
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([user.email_address])
      expect(mail.subject).to eq(I18n.t('passwords.mailer.reset.subject'))
    end

    it 'does not send an email when the address is unknown' do
      expect {
        post passwords_path, params: { email_address: 'unknown@drivecash.test' }
      }.not_to change { ActionMailer::Base.deliveries.size }
    end

    it 'redirects to the login page with the same neutral notice in both cases' do
      post passwords_path, params: { email_address: 'unknown@drivecash.test' }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:notice]).to eq(I18n.t('passwords.instructions_sent'))

      post passwords_path, params: { email_address: user.email_address }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:notice]).to eq(I18n.t('passwords.instructions_sent'))
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
  end
end

require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'GET /registrations/new' do
    it 'renders the registration view with BrandMark and headline' do
      get new_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('registrations.new_view.headline'))
      expect(response.body).to include(I18n.t('registrations.new_view.name_label'))
      expect(response.body).to include(I18n.t('registrations.new_view.password_confirmation_label'))
      expect(response.body).to include('viewBox="0 0 100 100"')
    end

    it 'renders the desktop brand panel' do
      get new_registration_path

      expect(response.body).to include('lg:flex')
      expect(response.body).to include(I18n.t('sessions.new_view.brand_headline_line1'))
    end

    it 'links to the login screen' do
      get new_registration_path

      expect(response.body).to include("href=\"#{new_session_path}\"")
    end

    it 'redirects to root with notice when already authenticated' do
      user = create(:user)
      login_as(user)

      get new_registration_path

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq(I18n.t('registrations.already_signed_in'))
    end
  end

  describe 'POST /registrations' do
    let(:valid_params) do
      {
        user: {
          name:                  'New Driver',
          email_address:         'new-driver@gmail.com',
          password:              'password123',
          password_confirmation: 'password123'
        }
      }
    end

    it 'redirects to root with notice when already authenticated' do
      user = create(:user)
      login_as(user)

      post registrations_path, params: valid_params

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq(I18n.t('registrations.already_signed_in'))
    end

    it 'creates a user, starts a session and redirects to root with flash welcome' do
      expect { post registrations_path, params: valid_params }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq(I18n.t('registrations.welcome'))
    end

    it 'returns 422 when email is already taken' do
      create(:user, email_address: 'new-driver@gmail.com')

      post registrations_path, params: valid_params

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('registrations.new_view.headline'))
    end

    it 'returns 422 when password is shorter than 8 characters' do
      params = valid_params.deep_dup
      params[:user][:password] = 'short'
      params[:user][:password_confirmation] = 'short'

      post registrations_path, params: params

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns 422 when password_confirmation does not match password' do
      params = valid_params.deep_dup
      params[:user][:password_confirmation] = 'different123'

      post registrations_path, params: params

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('activerecord.attributes.user.password_confirmation'))
      expect(response.body).not_to include('Password confirmation')
    end

    it 'returns 422 with a readable domain error when email provider is not allowed' do
      params = valid_params.deep_dup
      params[:user][:email_address] = 'user@empresa.com'

      post registrations_path, params: params

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('activerecord.attributes.user.email_address'))
      expect(response.body).not_to include('Email address')
    end

    it 'returns 422 when name is blank' do
      params = valid_params.deep_dup
      params[:user][:name] = ''

      post registrations_path, params: params

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end

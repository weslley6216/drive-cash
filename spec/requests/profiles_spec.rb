require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user, name: 'Weslley Souza', email_address: 'weslley@gmail.com', phone: '(11) 98765-4321') }

  describe 'GET /profile/edit' do
    it 'redirects to login when unauthenticated' do
      get edit_profile_path

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the profile form with current values' do
        get edit_profile_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Weslley Souza')
        expect(response.body).to include('weslley@gmail.com')
        expect(response.body).to include('(11) 98765-4321')
      end

      it 'renders the security disclosure with the three password fields' do
        get edit_profile_path

        expect(response.body).to include('data-controller="disclosure"')
        expect(response.body).to include('name="user[current_password]"')
        expect(response.body).to include('name="user[password]"')
        expect(response.body).to include('name="user[password_confirmation]"')
      end

      it 'links the back button to the account hub' do
        get edit_profile_path

        expect(response.body).to include('href="/account"')
      end
    end
  end
end

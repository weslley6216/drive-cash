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

      it 'renders each field once so a hidden layout cannot overwrite the edits on submit' do
        get edit_profile_path

        expect(response.body.scan('name="user[name]"').size).to eq(1)
        expect(response.body.scan('name="user[email_address]"').size).to eq(1)
        expect(response.body.scan('name="user[phone]"').size).to eq(1)
        expect(response.body.scan('name="user[password]"').size).to eq(1)
      end
    end
  end

  describe 'PATCH /profile' do
    before { login_as(user) }

    it 'updates name and phone without requiring the current password and redirects with a success notice' do
      patch profile_path, params: { user: { name: 'Novo Nome', phone: '(21) 90000-0000' } }

      expect(response).to redirect_to(edit_profile_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('profiles.flash.saved'))
      expect(user.reload.name).to eq('Novo Nome')
      expect(user.phone).to eq('(21) 90000-0000')
    end

    it 'changes the email when the current password is correct' do
      patch profile_path, params: { user: { email_address: 'novo@gmail.com', current_password: 'password123' } }

      expect(response).to redirect_to(edit_profile_path)
      expect(user.reload.email_address).to eq('novo@gmail.com')
    end

    it 'rejects an email change with an inline error when the current password is missing' do
      patch profile_path, params: { user: { email_address: 'novo@gmail.com' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('activerecord.errors.models.user.attributes.current_password.invalid'))
      expect(user.reload.email_address).to eq('weslley@gmail.com')
    end

    it 'changes the password when the current password is correct' do
      patch profile_path, params: { user: { current_password: 'password123', password: 'newpassword123', password_confirmation: 'newpassword123' } }

      expect(response).to redirect_to(edit_profile_path)
      expect(user.reload.authenticate('newpassword123')).to eq(user)
    end

    it 'rejects the password change with an inline error when the current password is wrong' do
      patch profile_path, params: { user: { current_password: 'wrong', password: 'newpassword123', password_confirmation: 'newpassword123' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('activerecord.errors.models.user.attributes.current_password.invalid'))
      expect(user.reload.authenticate('newpassword123')).to be(false)
    end

    it 're-renders with 422 when the name is blank' do
      patch profile_path, params: { user: { name: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.name).to eq('Weslley Souza')
    end

    it 'keeps the password unchanged when the password fields are left blank' do
      patch profile_path, params: { user: { name: 'Só Nome', password: '', password_confirmation: '' } }

      expect(response).to redirect_to(edit_profile_path)
      expect(user.reload.authenticate('password123')).to eq(user)
    end
  end
end

require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  let(:user) { create(:user, name: 'Weslley Souza', email_address: 'weslley@gmail.com', phone: '(11) 98765-4321') }

  def elevate_session
    user.sessions.last.reauthenticate!
  end

  describe 'GET /profile/edit' do
    it 'redirects to login when unauthenticated' do
      get edit_profile_path

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the profile form with the current name and phone' do
        get edit_profile_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Weslley Souza')
        expect(response.body).to include('(11) 98765-4321')
      end

      it 'locks email and password behind a reauthentication prompt when the session is not elevated' do
        get edit_profile_path

        expect(response.body).to include(I18n.t('profiles.edit_view.email_locked'))
        expect(response.body).to include(I18n.t('profiles.edit_view.password_locked'))
        expect(response.body).to include('href="/reauthentication/new"')
        expect(response.body).not_to include('name="user[email_address]"')
        expect(response.body).not_to include('name="user[password]"')
      end

      it 'renders editable email and password fields when the session is elevated' do
        elevate_session

        get edit_profile_path

        expect(response.body).to include('name="user[email_address]"')
        expect(response.body).to include('name="user[password]"')
        expect(response.body).to include('name="user[password_confirmation]"')
      end
    end

    context 'when the account is managed by Google' do
      let(:google_user) { create(:user, provider: 'google_oauth2', uid: 'uid-1', email_address: 'g@gmail.com') }

      before { login_as(google_user) }

      it 'shows the email as read-only managed by Google and hides the password section' do
        get edit_profile_path

        expect(response.body).to include(I18n.t('profiles.edit_view.email_managed'))
        expect(response.body).to include('g@gmail.com')
        expect(response.body).not_to include('name="user[email_address]"')
        expect(response.body).not_to include('name="user[password]"')
        expect(response.body).not_to include('href="/reauthentication/new"')
        expect(response.body).not_to include(I18n.t('profiles.edit_view.password_locked'))
      end
    end
  end

  describe 'PATCH /profile' do
    before { login_as(user) }

    it 'updates name and phone without elevation and redirects with a success notice' do
      patch profile_path, params: { user: { name: 'Novo Nome', phone: '(21) 90000-0000' } }

      expect(response).to redirect_to(edit_profile_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('profiles.flash.saved'))
      expect(user.reload.name).to eq('Novo Nome')
      expect(user.phone).to eq('(21) 90000-0000')
    end

    it 're-renders with 422 when the name is blank' do
      patch profile_path, params: { user: { name: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.name).to eq('Weslley Souza')
    end

    it 'redirects to the reauthentication challenge when changing the email without an elevated session' do
      patch profile_path, params: { user: { email_address: 'novo@gmail.com' } }

      expect(response).to redirect_to(new_reauthentication_path)
      expect(user.reload.email_address).to eq('weslley@gmail.com')
    end

    it 'redirects to the reauthentication challenge when changing the password without an elevated session' do
      patch profile_path, params: { user: { password: 'newpassword123', password_confirmation: 'newpassword123' } }

      expect(response).to redirect_to(new_reauthentication_path)
      expect(user.reload.authenticate('newpassword123')).to be(false)
    end

    context 'with an elevated session' do
      before { elevate_session }

      it 'changes the email' do
        patch profile_path, params: { user: { email_address: 'novo@gmail.com' } }

        expect(response).to redirect_to(edit_profile_path)
        expect(user.reload.email_address).to eq('novo@gmail.com')
      end

      it 'changes the password' do
        patch profile_path, params: { user: { password: 'newpassword123', password_confirmation: 'newpassword123' } }

        expect(response).to redirect_to(edit_profile_path)
        expect(user.reload.authenticate('newpassword123')).to eq(user)
      end

      it 're-renders with 422 when the new password is too short' do
        patch profile_path, params: { user: { password: 'short', password_confirmation: 'short' } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(user.reload.authenticate('password123')).to eq(user)
      end
    end
  end
end

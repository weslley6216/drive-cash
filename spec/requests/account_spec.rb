require 'rails_helper'

RSpec.describe 'Account', type: :request do
  let(:user) { create(:user, name: 'Weslley Souza', email_address: 'weslley@gmail.com') }

  describe 'GET /account' do
    it 'redirects to login when unauthenticated' do
      get account_path

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the account view' do
        get account_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('account.show_view.heading'))
      end

      it 'renders the avatar with the first letter of the user name' do
        get account_path

        expect(response.body).to match(/<div[^>]+rounded-full[^>]+bg-blue-600[^>]*>\s*W\s*</)
      end

      it 'renders the user name and email in the profile card' do
        get account_path

        expect(response.body).to include('Weslley Souza')
        expect(response.body).to include('weslley@gmail.com')
      end

      it 'renders both account groups with their items' do
        get account_path

        expect(response.body).to include(I18n.t('account.groups.account'))
        expect(response.body).to include(I18n.t('account.groups.preferences'))
        expect(response.body).to include(I18n.t('account.items.personal_data.label'))
        expect(response.body).to include(I18n.t('account.items.plan.label'))
        expect(response.body).to include(I18n.t('account.items.notifications.label'))
        expect(response.body).to include(I18n.t('account.items.vehicle.label'))
        expect(response.body).to include(I18n.t('account.items.export.label'))
        expect(response.body).to include(I18n.t('account.items.help.label'))
      end

      it 'renders the Free badge on the plan item' do
        get account_path

        expect(response.body).to include(I18n.t('account.items.plan.badge'))
      end

      it 'links the vehicle item to vehicle_path and other items to coming_soon' do
        get account_path

        expect(response.body).to include('href="/vehicle"')
        expect(response.body).to include('href="/coming_soon"').or include('coming_soon')
      end

      it 'renders the sign out button with red border' do
        get account_path

        expect(response.body).to include(I18n.t('account.show_view.sign_out_button'))
        expect(response.body).to include('border-red-200')
        expect(response.body).to include('text-red-600')
      end

      it 'wires the confirm-action stimulus controller on the sign out buttons' do
        get account_path

        expect(response.body.scan('data-controller="confirm-action"').size).to be >= 2
        expect(response.body.scan('data-action="click->confirm-action#open"').size).to be >= 2
      end

      it 'renders logout confirmation overlays hidden by default' do
        get account_path

        expect(response.body.scan('data-confirm-action-target="overlay"').size).to be >= 2
      end

      it 'renders the desktop session block with sign out short label' do
        get account_path

        expect(response.body).to include(I18n.t('account.show_view.session_description'))
        expect(response.body).to include(I18n.t('account.show_view.sign_out_short'))
      end

      it 'renders the desktop edit profile button' do
        get account_path

        expect(response.body).to include(I18n.t('account.show_view.edit_profile'))
      end

      it 'renders the version footer' do
        get account_path

        expect(response.body).to match(/DriveCash · versão/)
      end

      it 'renders the desktop sidebar' do
        get account_path

        expect(response.body).to include('lg:flex lg:flex-col lg:w-64')
      end

      it 'submits the logout via a DELETE /session form' do
        get account_path

        expect(response.body).to include('action="/session"')
        expect(response.body).to include('name="_method" value="delete"')
      end
    end
  end
end

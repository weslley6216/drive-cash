require 'rails_helper'

RSpec.describe 'Notification preferences', type: :request do
  let(:user) { create(:user) }

  describe 'GET /notification_preferences/edit' do
    it 'redirects to login when unauthenticated' do
      get edit_notification_preferences_path

      expect(response).to redirect_to(new_session_path)
    end

    it 'renders the five kinds for the current user' do
      login_as(user)

      get edit_notification_preferences_path

      expect(response).to have_http_status(:ok)
      Notifications::Registry::KINDS.each do |kind|
        expect(response.body).to include(I18n.t("notifications.preferences.kinds.#{kind}.title"))
      end
    end

    it 'opts out of the Turbo snapshot cache' do
      login_as(user)

      get edit_notification_preferences_path

      expect(response.body).to include('name="turbo-cache-control" content="no-cache"')
    end
  end

  describe 'PATCH /notification_preferences' do
    it 'redirects to login when unauthenticated' do
      patch notification_preferences_path, params: { kind: 'tank_low', enabled: 'false' }

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'disables the kind and flashes the muted toast payload' do
        patch notification_preferences_path, params: { kind: 'log_reminder', enabled: 'false' }

        expect(flash[:muted]).to eq('kind' => 'log_reminder')
        expect(response).to redirect_to(edit_notification_preferences_path)
      end

      it 're-enables the kind without a toast' do
        user.update!(notification_preferences: { 'log_reminder' => false })

        patch notification_preferences_path, params: { kind: 'log_reminder', enabled: 'true' }

        expect(flash[:muted]).to be_nil
        expect(response).to redirect_to(edit_notification_preferences_path)
      end

      it 'refreshes the page for turbo stream requests' do
        patch notification_preferences_path, params: { kind: 'log_reminder', enabled: 'false' }, as: :turbo_stream

        expect(response.body).to include('action="refresh"')
      end

      it 'rejects an unknown kind' do
        patch notification_preferences_path, params: { kind: 'foo', enabled: 'false' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(user.reload.notification_preferences).to eq({})
      end

      it "changes only the current user's preferences" do
        other = create(:user)

        patch notification_preferences_path, params: { kind: 'log_reminder', enabled: 'false' }

        expect(other.reload.notification_preferences).to eq({})
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Notifications', type: :request do
  let(:user) { create(:user) }

  describe 'GET /notifications' do
    it 'redirects to login when unauthenticated' do
      get notifications_path

      expect(response).to redirect_to(new_session_path)
    end

    context 'when authenticated' do
      before { login_as(user) }

      it 'renders the empty state when the user has no notifications' do
        get notifications_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t('notifications.index.empty.title'))
        expect(response.body).to include(I18n.t('notifications.index.empty.description'))
      end

      it 'hides the mark-all action when there is nothing to read' do
        get notifications_path

        expect(response.body).not_to include(I18n.t('notifications.index.read_all'))
      end

      it 'groups notifications by time bucket' do
        create(:notification, user: user, kind: 'tank_low', data: { 'status' => 'negative' }, created_at: Time.current)
        create(:notification, user: user, kind: 'log_reminder', created_at: 3.weeks.ago)

        get notifications_path

        expect(response.body).to include(I18n.t('notifications.index.groups.today'))
        expect(response.body).to include(I18n.t('notifications.index.groups.earlier'))
        expect(response.body).to include('Tanque no vermelho')
        expect(response.body).to include('Registre o seu dia')
      end

      it 'shows the unread count on the desktop header' do
        create(:notification, user: user)

        get notifications_path

        expect(response.body).to include(I18n.t('notifications.index.unread_count', count: 1))
      end

      it 'generates notifications from the domain on load' do
        create(:earning, user: user, date: 4.days.ago.to_date)

        expect { get notifications_path }.to change { user.notifications.count }.from(0)
      end

      it 'does not duplicate generated notifications across loads' do
        create(:earning, user: user, date: 4.days.ago.to_date)
        get notifications_path

        expect { get notifications_path }.not_to change { user.notifications.count }
      end

      it 'never shows notifications belonging to another user' do
        create(:notification, user: create(:user), kind: 'tank_low', data: { 'status' => 'negative' })

        get notifications_path

        expect(response.body).not_to include('Tanque no vermelho')
      end
    end
  end

  describe 'PATCH /notifications/:id/read' do
    before { login_as(user) }

    it 'marks a single notification as read' do
      notification = create(:notification, user: user)

      patch read_notification_path(notification)

      expect(notification.reload.read_at).to be_present
    end

    it 'responds with a turbo refresh stream' do
      notification = create(:notification, user: user)

      patch read_notification_path(notification), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include('action="refresh"')
    end

    it 'redirects back to the center on an html request' do
      notification = create(:notification, user: user)

      patch read_notification_path(notification)

      expect(response).to redirect_to(notifications_path)
    end

    it 'does not mark a notification belonging to another user' do
      notification = create(:notification, user: create(:user))

      patch read_notification_path(notification)

      expect(response).to have_http_status(:not_found)
      expect(notification.reload.read_at).to be_nil
    end
  end

  describe 'PATCH /notifications/read_all' do
    before { login_as(user) }

    it 'marks every unread notification as read' do
      first = create(:notification, user: user)
      second = create(:notification, user: user)

      patch read_all_notifications_path

      expect(first.reload.read_at).to be_present
      expect(second.reload.read_at).to be_present
    end

    it 'leaves notifications of other users untouched' do
      other = create(:notification, user: create(:user))

      patch read_all_notifications_path

      expect(other.reload.read_at).to be_nil
    end
  end
end

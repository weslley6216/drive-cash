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

      it 'links to the preferences when empty' do
        get notifications_path

        expect(response.body).to include('href="/notification_preferences/edit"')
        expect(response.body).to include('aria-label="Preferências"')
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

      it 'links to the preferences' do
        create(:notification, user: user)

        get notifications_path

        expect(response.body).to include('href="/notification_preferences/edit"')
        expect(response.body).to include('aria-label="Preferências"')
      end

      it 'generates notifications from the domain on load' do
        travel_to Date.new(2026, 7, 14) do
          create(:earning, user: user, date: Date.new(2026, 7, 10))

          expect { get notifications_path }.to change { user.notifications.count }.from(0)
        end
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

      it 'hides a dismissed notification from the list' do
        create(:notification, user: user, kind: 'tank_low', data: { 'status' => 'negative' }, dismissed_at: Time.current)

        get notifications_path

        expect(response.body).not_to include('Tanque no vermelho')
      end

      it 'hides notifications of a disabled kind from the list and the unread count' do
        create(:notification, user: user, kind: 'tank_low', data: { 'status' => 'negative' })
        create(:notification, user: user, kind: 'log_reminder')
        user.update!(notification_settings: user.notification_settings.with('log_reminder', false))

        get notifications_path

        expect(response.body).to include('Tanque no vermelho')
        expect(response.body).not_to include('Registre o seu dia')
        expect(response.body).to include(I18n.t('notifications.index.unread_count', count: 1))
      end

      it 'hides a notification read more than a week ago and keeps an old unread one' do
        create(:notification, user: user, kind: 'tank_low', data: { 'status' => 'negative' }, read_at: 8.days.ago)
        create(:notification, user: user, kind: 'log_reminder', created_at: 1.month.ago)

        get notifications_path

        expect(response.body).not_to include('Tanque no vermelho')
        expect(response.body).to include('Registre o seu dia')
      end
    end
  end

  describe 'PATCH /notifications/:id/open' do
    before { login_as(user) }

    it 'marks the notification read and redirects to its destination' do
      notification = create(:notification, user: user, kind: 'log_reminder', data: { 'date' => '2026-07-14' })

      patch open_notification_path(notification)

      expect(response).to redirect_to('/history?focus_day=2026-07-13&highlight=day-2026-07-13')
      expect(response).to have_http_status(:see_other)
      expect(notification.reload.read_at).to be_present
    end

    it 'redirects to the inline destination when tapped inline' do
      notification = create(:notification, user: user, kind: 'maintenance_due',
                                           data: { 'maintenance_id' => 1, 'status' => 'overdue',
                                                   'category' => 'oil_change', 'km_until' => -412,
                                                   'interval_km' => 5_000 })

      patch open_notification_path(notification, via: 'inline')

      expect(response).to redirect_to('/maintenances/1/mark_done/new')
    end

    it 'returns 404 for another user notification on open' do
      notification = create(:notification, user: create(:user))

      patch open_notification_path(notification)

      expect(response).to have_http_status(:not_found)
      expect(notification.reload.read_at).to be_nil
    end
  end

  describe 'DELETE /notifications/:id' do
    before { login_as(user) }

    it 'dismisses the notification' do
      notification = create(:notification, user: user)

      delete notification_path(notification)

      expect(notification.reload.dismissed_at).to be_present
      expect(Notification.count).to eq(1)
      expect(response).to redirect_to(notifications_path)
    end

    it 'returns 404 for another user notification on destroy' do
      notification = create(:notification, user: create(:user))

      delete notification_path(notification)

      expect(response).to have_http_status(:not_found)
      expect(notification.reload.dismissed_at).to be_nil
    end

    it 'does not recreate a dismissed notification on the next visit' do
      travel_to Date.new(2026, 7, 14) do
        create(:earning, user: user, date: Date.new(2026, 7, 10))

        get notifications_path
        user.notifications.each(&:dismiss!)
        get notifications_path

        expect(user.notifications.visible.count).to eq(0)
      end
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

    it 'keeps unread the notifications of a disabled kind' do
      user.update!(notification_settings: user.notification_settings.with('log_reminder', false))
      hidden = create(:notification, user: user, kind: 'log_reminder')
      shown = create(:notification, user: user, kind: 'tank_low', data: { 'status' => 'negative' })

      patch read_all_notifications_path

      expect(hidden.reload.read_at).to be_nil
      expect(shown.reload.read_at).to be_present
    end

    it 'leaves notifications of other users untouched' do
      other = create(:notification, user: create(:user))

      patch read_all_notifications_path

      expect(other.reload.read_at).to be_nil
    end
  end

  describe 'DELETE /notifications/clear' do
    before { login_as(user) }

    it 'dismisses only the read notifications and redirects to the center' do
      read = create(:notification, user: user, read_at: Time.current)
      unread = create(:notification, user: user)

      delete clear_notifications_path

      expect(read.reload.dismissed_at).to be_present
      expect(unread.reload.dismissed_at).to be_nil
      expect(response).to redirect_to(notifications_path)
    end

    it 'answers a turbo stream refresh' do
      create(:notification, user: user, read_at: Time.current)

      delete clear_notifications_path, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include('action="refresh"')
    end

    it 'leaves notifications of other users untouched' do
      other = create(:notification, user: create(:user), read_at: Time.current)

      delete clear_notifications_path

      expect(other.reload.dismissed_at).to be_nil
    end

    it 'does not recreate cleared notifications on the next visit' do
      travel_to Date.new(2026, 7, 14) do
        create(:earning, user: user, date: Date.new(2026, 7, 10))
        get notifications_path
        patch read_all_notifications_path
        generated = user.notifications.read.count

        delete clear_notifications_path
        get notifications_path

        expect(generated).to be_positive
        expect(user.notifications.count).to eq(generated)
        expect(user.notifications.visible.count).to eq(0)
        expect(response.body).to include(I18n.t('notifications.index.empty.title'))
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Notifications::IndexView, type: :component do
  let(:user) { create(:user) }
  let(:groups) { Notifications::Grouping.new(user.visible_notifications.recent).call }
  let(:html) do
    view_context.render(described_class.new(groups: groups, unread_count: user.visible_notifications.unread.count))
  end

  before do
    allow(Current).to receive(:user).and_return(user)
  end

  context 'with an unread notification' do
    before { create(:notification, user: user) }

    it 'offers to mark all as read' do
      expect(html).to include(I18n.t('notifications.index.read_all'))
      expect(html).to include('action="/notifications/read_all"')
      expect(html).not_to include(I18n.t('notifications.index.clear_all'))
    end
  end

  context 'with every notification read' do
    before { create(:notification, user: user, read_at: Time.current) }

    it 'offers to clear all instead' do
      expect(html).to include(I18n.t('notifications.index.clear_all'))
      expect(html).to include('action="/notifications/clear"')
      expect(html).not_to include(I18n.t('notifications.index.read_all'))
    end

    it 'sends the clear as a DELETE' do
      expect(html).to include('name="_method" value="delete"')
    end
  end

  context 'without notifications' do
    it 'shows the empty state with no header action' do
      expect(html).to include(I18n.t('notifications.index.empty.title'))
      expect(html).not_to include(I18n.t('notifications.index.read_all'))
      expect(html).not_to include(I18n.t('notifications.index.clear_all'))
    end
  end
end

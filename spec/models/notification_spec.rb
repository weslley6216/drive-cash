require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:kind) }

  it 'defaults data to an empty hash' do
    notification = described_class.create!(user: user, kind: 'log_reminder')

    expect(notification.data).to eq({})
  end

  describe 'kind validation' do
    it 'accepts a kind backed by a generator' do
      notification = build(:notification, kind: 'maintenance_due')

      expect(notification).to be_valid
    end

    it 'rejects a kind without a generator' do
      notification = build(:notification, kind: 'array')

      notification.valid?

      expect(notification.errors[:kind]).to be_present
    end
  end

  describe '.unread' do
    it 'returns only notifications without read_at' do
      unread = create(:notification, user: user)
      create(:notification, user: user, read_at: Time.current)

      expect(described_class.unread).to contain_exactly(unread)
    end
  end

  describe '.chronological' do
    it 'orders from newest to oldest' do
      older = create(:notification, user: user, created_at: 2.days.ago)
      newer = create(:notification, user: user, created_at: 1.hour.ago)

      expect(described_class.chronological).to eq([newer, older])
    end
  end

  describe '.recent' do
    it 'keeps the newest notifications up to the limit and drops the oldest' do
      newest = create(:notification, user: user, created_at: 1.minute.ago)
      oldest = create(:notification, user: user, created_at: 1.year.ago)
      (described_class::INDEX_LIMIT - 1).times do |offset|
        create(:notification, user: user, created_at: (offset + 1).hours.ago)
      end

      result = described_class.recent

      expect(result.size).to eq(described_class::INDEX_LIMIT)
      expect(result).to include(newest)
      expect(result).not_to include(oldest)
    end
  end

  describe '.mark_all_read!' do
    it 'stamps read_at on every notification in the relation' do
      notification = create(:notification, user: user)

      user.notifications.unread.mark_all_read!

      expect(notification.reload.read_at).to be_present
    end
  end

  describe '#mark_read!' do
    it 'stamps read_at when the notification is unread' do
      notification = create(:notification, user: user)

      notification.mark_read!

      expect(notification.read_at).to be_present
    end

    it 'keeps the original read_at when already read' do
      original = 3.days.ago.change(usec: 0)
      notification = create(:notification, user: user, read_at: original)

      notification.mark_read!

      expect(notification.reload.read_at).to eq(original)
    end
  end

  describe '#unread?' do
    it 'is true without read_at and false with it' do
      expect(build(:notification, read_at: nil)).to be_unread
      expect(build(:notification, read_at: Time.current)).not_to be_unread
    end
  end
end

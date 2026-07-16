require 'rails_helper'

RSpec.describe Notifications::Grouping do
  let(:user) { create(:user) }
  let(:date) { Date.new(2026, 7, 15) }

  it 'buckets notifications into today, this week and earlier, in that order' do
    today = create(:notification, user: user, created_at: date.to_time.change(hour: 9))
    this_week = create(:notification, user: user, created_at: Date.new(2026, 7, 13).to_time.change(hour: 18))
    earlier = create(:notification, user: user, created_at: Date.new(2026, 7, 4).to_time.change(hour: 8))

    groups = described_class.new(user.notifications.chronological, date: date).call

    expect(groups.map(&:key)).to eq(%i[today week earlier])
    expect(groups.map { |group| group.rows.map(&:notification) }).to eq([[today], [this_week], [earlier]])
  end

  it 'omits buckets with no notifications' do
    create(:notification, user: user, created_at: date.to_time.change(hour: 9))

    groups = described_class.new(user.notifications.chronological, date: date).call

    expect(groups.map(&:key)).to eq([:today])
  end

  it 'returns no groups when there are no notifications' do
    groups = described_class.new(user.notifications.chronological, date: date).call

    expect(groups).to be_empty
  end

  it 'presents each notification into a row' do
    create(:notification, user: user, kind: 'log_reminder', created_at: date.to_time.change(hour: 9))

    groups = described_class.new(user.notifications.chronological, date: date).call

    expect(groups.first.rows.first.title).to eq('Registre o seu dia')
  end
end

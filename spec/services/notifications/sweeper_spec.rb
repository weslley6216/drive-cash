require 'rails_helper'

RSpec.describe Notifications::Sweeper do
  let(:user) { create(:user) }
  let(:date) { Date.new(2026, 7, 14) }

  it 'creates a notification for each detected condition' do
    create(:earning, user: user, date: Date.new(2026, 7, 10))

    created = described_class.new(user: user, date: date).call

    expect(created.map(&:kind)).to contain_exactly('log_reminder', 'weekly_summary')
  end

  it 'does not duplicate a notification already created for the same window' do
    create(:earning, user: user, date: Date.new(2026, 7, 10))
    described_class.new(user: user, date: date).call

    created = described_class.new(user: user, date: date).call

    expect(created).to be_empty
    expect(user.notifications.count).to eq(2)
  end

  it 'creates a new notification once the dedup window moves on' do
    create(:earning, user: user, date: Date.new(2026, 7, 10))
    described_class.new(user: user, date: date).call

    described_class.new(user: user, date: date + 1).call

    expect(user.notifications.where(kind: 'log_reminder').count).to eq(2)
  end

  it 'ignores an identical notification belonging to another user' do
    create(:earning, user: user, date: Date.new(2026, 7, 10))
    create(:notification, user: create(:user), kind: 'log_reminder', data: { 'date' => '2026-07-14' })

    created = described_class.new(user: user, date: date).call

    expect(created.map(&:kind)).to include('log_reminder')
  end

  it 'creates nothing when no generator detects a condition' do
    created = described_class.new(user: user, date: date).call

    expect(created).to be_empty
  end
end

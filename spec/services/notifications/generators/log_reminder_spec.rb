require 'rails_helper'

RSpec.describe Notifications::Generators::LogReminder do
  let(:user) { create(:user) }
  let(:date) { Date.new(2026, 7, 14) }
  let(:context) { Notifications::Context.new(user: user, date: date) }

  it 'emits a reminder when an active driver logged nothing yesterday' do
    create(:earning, user: user, date: Date.new(2026, 7, 10))

    payloads = described_class.new(context).call

    expect(payloads).to contain_exactly(
      hash_including(kind: 'log_reminder', data: { 'date' => '2026-07-14' }, dedup: { 'date' => '2026-07-14' })
    )
  end

  it 'emits nothing when the driver already logged yesterday' do
    create(:earning, user: user, date: Date.new(2026, 7, 10))
    create(:earning, user: user, date: Date.new(2026, 7, 13))

    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end

  it 'emits nothing for a driver with no recent activity' do
    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end
end

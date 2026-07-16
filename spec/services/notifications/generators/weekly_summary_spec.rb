require 'rails_helper'

RSpec.describe Notifications::Generators::WeeklySummary do
  let(:user) { create(:user) }
  let(:date) { Date.new(2026, 7, 14) }
  let(:last_week) { Date.new(2026, 7, 8) }
  let(:context) { Notifications::Context.new(user: user, date: date) }

  it 'emits last week profit and trips when the user worked' do
    create(:earning, user: user, date: last_week, amount: 1_000, trips_count: 30)
    create(:expense, user: user, date: last_week, amount: 250, paid: true)

    payloads = described_class.new(context).call

    expect(payloads).to contain_exactly(
      hash_including(
        kind:  'weekly_summary',
        data:  { 'week_start' => '2026-07-05', 'profit' => 750.0, 'trips' => 30 },
        dedup: { 'week_start' => '2026-07-05' }
      )
    )
  end

  it 'emits nothing when the user did not work last week' do
    create(:earning, user: user, date: date, amount: 900, trips_count: 20)

    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end
end

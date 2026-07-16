require 'rails_helper'

RSpec.describe Notifications::Generators::TankLow do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }
  let(:context) { Notifications::Context.new(user: user, date: Date.current) }

  it 'emits a payload when fuel expenses outran the tank balance' do
    refueling = create(:refueling, vehicle: vehicle, date: 10.days.ago.to_date, total_amount: 100, full_tank: true)
    create(:expense, user: user, category: 'fuel', date: 2.days.ago.to_date, amount: 180, paid: true)

    payloads = described_class.new(context).call

    expect(payloads).to contain_exactly(
      hash_including(
        kind:  'tank_low',
        data:  hash_including('status' => 'negative', 'balance' => -80.0, 'last_fill_id' => refueling.id),
        dedup: { 'status' => 'negative', 'last_fill_id' => refueling.id }
      )
    )
  end

  it 'emits nothing when the tank balance is healthy' do
    create(:refueling, vehicle: vehicle, date: 2.days.ago.to_date, total_amount: 100, full_tank: true)

    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end
end

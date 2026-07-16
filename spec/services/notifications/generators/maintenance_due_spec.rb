require 'rails_helper'

RSpec.describe Notifications::Generators::MaintenanceDue do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user, odometer_km: 50_000) }
  let(:context) { Notifications::Context.new(user: user, date: Date.current) }

  it 'emits an overdue payload when the maintenance passed its interval' do
    maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 44_000,
                                       interval_km: 5_000)

    payloads = described_class.new(context).call

    expect(payloads).to contain_exactly(
      hash_including(
        kind:  'maintenance_due',
        data:  hash_including('maintenance_id' => maintenance.id, 'status' => 'overdue',
                              'category' => 'oil_change', 'km_until' => -1_000),
        dedup: { 'maintenance_id' => maintenance.id, 'status' => 'overdue' }
      )
    )
  end

  it 'emits a soon payload when the maintenance crossed the soon threshold' do
    create(:maintenance, vehicle: vehicle, category: 'tire_rotation', last_done_km: 41_000, interval_km: 10_000)

    payloads = described_class.new(context).call

    expect(payloads.first).to include(kind: 'maintenance_due', dedup: hash_including('status' => 'soon'))
  end

  it 'emits nothing when every maintenance is still on schedule' do
    create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 49_000, interval_km: 10_000)

    payloads = described_class.new(context).call

    expect(payloads).to be_empty
  end

  it 'emits nothing when the user has no vehicle' do
    payloads = described_class.new(Notifications::Context.new(user: create(:user), date: Date.current)).call

    expect(payloads).to be_empty
  end
end

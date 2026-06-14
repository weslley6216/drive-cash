require 'rails_helper'

RSpec.describe 'Vehicle flow', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'registers a vehicle via PATCH and refreshes via turbo' do
    patch vehicle_path,
          params: {
            vehicle: { brand: 'Honda', vehicle_model: 'Civic', year: '2018',
                       license_plate: 'ABC-1D23', odometer_km: '160928' }
          },
          as:     :turbo_stream

    expect(response.body).to include('action="refresh"')
    expect(current_user.reload.vehicle.odometer_km).to eq(160_928)
  end

  it 'credits the tank on refuel then goes negative after fuel expenses' do
    vehicle = create(:vehicle, user: current_user, odometer_km: 160_928)

    post refuelings_path,
         params: { refueling: { date: Date.current.to_s, vendor: 'Posto Orense', liters: '44.1',
                                total_amount: '260.00', odometer_km: '160928', full_tank: '1' } },
         as:     :turbo_stream
    get vehicle_path

    expect(response.body).to include(I18n.t('vehicle.tank.status.ok'))
    expect(response.body).to include('R$ 260,00')

    create(:expense, user: current_user, category: 'fuel', amount: 300, date: Date.current)
    get vehicle_path

    expect(response.body).to include(I18n.t('vehicle.tank.status.negative'))
    expect(response.body).to include(I18n.t('vehicle.tank.note.negative'))
    expect(vehicle.reload.refuelings.count).to eq(1)
  end

  it 'resets odometer freshness after an update' do
    create(:vehicle, user: current_user, odometer_km: 160_000, odometer_updated_at: 30.days.ago)

    patch vehicle_path, params: { vehicle: { odometer_km: '160928' } }, as: :turbo_stream
    get vehicle_path

    expect(response.body).to include(I18n.t('vehicle.odometer.fresh', count: 0))
  end

  it 'zeroes maintenance progress when marked done' do
    vehicle = create(:vehicle, user: current_user, odometer_km: 160_928)
    maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 150_000, interval_km: 5_000)

    patch mark_done_maintenance_path(maintenance), as: :turbo_stream

    expect(maintenance.reload.progress).to eq(0)
  end
end

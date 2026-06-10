require 'rails_helper'

RSpec.describe 'Vehicle flow', type: :request do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'registers a vehicle via PATCH and redirects to dashboard' do
    patch vehicle_path, params: {
      vehicle: { brand: 'Honda', vehicle_model: 'Civic', year: '2018',
                 license_plate: 'ABC-1D23', odometer_km: '48230' }
    }

    expect(response).to redirect_to(vehicle_path)
    expect(current_user.reload.vehicle).to be_present
    expect(current_user.vehicle.brand).to eq('Honda')
    expect(current_user.vehicle.odometer_km).to eq(48_230)
  end

  it 'renders vehicle dashboard after registration' do
    create(:vehicle, user: current_user, brand: 'Honda', vehicle_model: 'Civic',
                     year: 2018, odometer_km: 48_230)

    get vehicle_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include('48.230')
    expect(response.body).to include(I18n.t('vehicle.metrics.cost_per_km'))
  end
end

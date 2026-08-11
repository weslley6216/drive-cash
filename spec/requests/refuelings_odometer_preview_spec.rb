require 'rails_helper'

RSpec.describe 'Odometer preview on the refueling form', type: :request do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user, odometer_km: 160_928) }

  before do
    vehicle
    login_as(user)
  end

  it 'wraps the odometer field in the odometer-preview controller with its target slots' do
    get new_refueling_path

    expect(response.body).to include('data-controller="odometer-preview"')
    expect(response.body).to include('data-odometer-preview-current-km-value="160928"')
    expect(response.body).to include('data-odometer-preview-target="advance"')
    expect(response.body).to include(I18n.t('refuelings.form.odometer_preview.title_advance'))
    expect(response.body).to include('data-odometer-preview-target="warn"')
    expect(response.body).to include(I18n.t('refuelings.form.odometer_preview.cannot_recede',
                                            current: ActiveSupport::NumberHelper.number_to_delimited(160_928)))
    expect(response.body).to include('data-odometer-preview-target="advanceLine"')
  end
end

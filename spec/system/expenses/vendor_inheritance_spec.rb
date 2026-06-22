require 'rails_helper'

RSpec.describe 'Vendor inheritance on the expense form', type: :request do
  let(:user) { create(:user) }
  let(:vehicle) { create(:vehicle, user: user) }

  before do
    vehicle
    create(:refueling, vehicle: vehicle, vendor: 'Posto Orense', full_tank: true, date: Date.current - 2)
    login_as(user)
  end

  it 'passes the active tank vendor as a Stimulus value when re-rendering after a fuel validation error' do
    post expenses_path, params: { expense: { amount: 0, category: 'fuel' } }, as: :turbo_stream

    expect(response.body).to include('data-refueling-fields-active-vendor-value="Posto Orense"')
  end

  it 'renders the vendorHint target slot' do
    post expenses_path, params: { expense: { amount: 0, category: 'fuel' } }, as: :turbo_stream

    expect(response.body).to include('data-refueling-fields-target="vendorHint"')
    expect(response.body).to include(I18n.t('expenses.new_view.vendor_inherited'))
  end

  it 'renders the vendorSuggest target slot with the chip text' do
    post expenses_path, params: { expense: { amount: 0, category: 'fuel' } }, as: :turbo_stream

    expect(response.body).to include('data-refueling-fields-target="vendorSuggest"')
    expect(response.body).to include(I18n.t('expenses.new_view.vendor_from_tank'))
  end

  it 'renders the vendorInput target on the vendor field' do
    post expenses_path, params: { expense: { amount: 0, category: 'fuel' } }, as: :turbo_stream

    expect(response.body).to include('data-refueling-fields-target="vendorInput"')
  end

  it 'does not pass active vendor when re-rendering an edit form for a persisted expense' do
    expense = create(:expense, user: user, category: 'fuel')

    get edit_expense_path(expense)

    expect(response.body).not_to include('data-refueling-fields-active-vendor-value')
  end

  it 'shows no hint slots when the user has no full_tank refueling' do
    user_no_tank = create(:user)
    create(:vehicle, user: user_no_tank)
    login_as(user_no_tank)

    post expenses_path, params: { expense: { amount: 0, category: 'fuel' } }, as: :turbo_stream

    expect(response.body).to include('data-refueling-fields-active-vendor-value=""')
  end
end

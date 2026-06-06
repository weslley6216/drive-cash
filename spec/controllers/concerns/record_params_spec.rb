require 'rails_helper'

RSpec.describe RecordParams, type: :controller do
  controller(ActionController::Base) do
    include RecordParams

    def show
      render json: { keys: expense_attribute_keys, earning: earning_attribute_keys, installment: installment_attribute_keys }
    end
  end

  before { routes.draw { get 'show' => 'anonymous#show' } }

  it 'exposes the expense attribute whitelist' do
    get :show

    expect(JSON.parse(response.body)['keys']).to match_array(%w[date amount category vendor description paid])
  end

  it 'exposes the earning attribute whitelist' do
    get :show

    expect(JSON.parse(response.body)['earning']).to match_array(%w[date amount platform notes trips_count])
  end

  it 'exposes the installment attribute whitelist' do
    get :show

    expect(JSON.parse(response.body)['installment']).to match_array(%w[repeat period repetitions])
  end
end

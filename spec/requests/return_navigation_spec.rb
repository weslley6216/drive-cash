require 'rails_helper'

RSpec.describe 'Return navigation', type: :request do
  let(:current_user) { create(:user) }
  let(:back_href) { Nokogiri::HTML5(response.body).at_css("a[aria-label='#{I18n.t('vehicle.back')}']")['href'] }

  before do
    create(:vehicle, user: current_user)
    login_as(current_user)
  end

  it 'sends the back to the screen that opened the page' do
    get vehicle_path(return_to: '/history?month=5')

    expect(back_href).to eq('/history?month=5')
  end

  it 'falls back to the fixed parent screen when the page opens directly' do
    get vehicle_path

    expect(back_href).to eq('/account')
  end

  it 'ignores a return to an external host' do
    get vehicle_path(return_to: 'https://evil.example/phish')

    expect(back_href).to eq('/account')
  end

  it 'ignores a protocol-relative return to an external host' do
    get vehicle_path(return_to: '//evil.example/phish')

    expect(back_href).to eq('/account')
  end

  it 'ignores a javascript return' do
    get vehicle_path(return_to: 'javascript:alert(1)')

    expect(back_href).to eq('/account')
  end
end

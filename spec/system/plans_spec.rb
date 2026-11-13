require 'rails_helper'

RSpec.describe 'Plans', type: :system, js: true do
  it 'keeps the plan header still past the prototype back arrow while the plans scroll on a phone' do
    login_as(create(:user))
    emulate_short_phone

    visit plan_path

    title = find('h1', text: I18n.t('plans.show_view.heading'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end

  it 'keeps the subscription header still past the prototype back arrow while the benefits scroll on a phone' do
    login_as(create(:user, :pro))
    emulate_short_phone

    visit plan_path

    title = find('h1', text: I18n.t('plans.subscription_view.heading'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end
end

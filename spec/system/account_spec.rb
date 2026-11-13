require 'rails_helper'

RSpec.describe 'Account', type: :system, js: true do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'keeps the account header still at the prototype 20px gutter while the groups scroll on a phone' do
    emulate_short_phone

    visit account_path

    title = find('h1', text: I18n.t('account.show_view.heading'))

    expect(box(title)['x'].round).to eq(20)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end
end

require 'rails_helper'

RSpec.describe 'Exports', type: :system, js: true do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'keeps the export header still past the prototype back arrow while the options scroll on a phone' do
    emulate_short_phone

    visit exports_path

    title = find('h1', text: I18n.t('exports.title'))

    expect(box(title)['x'].round).to eq(54)
    expect(title).to stay_pinned_while_the_content_scrolls
    expect(page).to fit_the_phone_width
  end
end

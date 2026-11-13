require 'rails_helper'

RSpec.describe 'Chat', type: :system, js: true do
  let(:current_user) { create(:user) }

  before { login_as(current_user) }

  it 'keeps the Caju header and the message box still while the messages scroll on a phone' do
    emulate_short_phone

    visit chat_root_path
    page.execute_script("document.getElementById('chat_messages').insertAdjacentHTML('beforeend', '<div style=\"height: 2000px\"></div>')")

    title = find('h1', text: I18n.t('chat.index.header'))
    screen = find('[data-controller="chat speech"]')
    message_box = box(find('textarea'))

    expect(box(title)['top'].round).to eq(24)
    expect(box(screen)['bottom'].round).to eq(ScreenGeometry::SHORT_PHONE_HEIGHT)
    expect(title).to stay_pinned_while_the_content_scrolls.in('#chat_messages')
    expect(box(find('textarea'))['top']).to eq(message_box['top'])
    expect(page).to fit_the_phone_width
  end
end

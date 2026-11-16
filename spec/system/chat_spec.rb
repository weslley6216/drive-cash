require 'rails_helper'

RSpec.describe 'Chat', type: :system, js: true do
  let(:current_user) { create(:user) }
  let(:release_answer) { Queue.new }
  let(:received_messages) { Queue.new }

  before { login_as(current_user) }
  after { release_answer << true }

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

  it 'lines up the bottom of the message box with the send button and the mic inside the box on a phone' do
    visit chat_root_path

    message_box = box(find('textarea[name="message"]'))
    send_button = box(find('button[type="submit"]'))
    mic = box(find('[data-speech-target="mic"]'))

    expect(send_button['bottom']).to eq(message_box['bottom'])
    expect(mic['top'] + (mic['height'] / 2)).to be_within(1).of(message_box['top'] + (message_box['height'] / 2))
    expect(page).to fit_the_phone_width
  end

  it 'clears the message box and shows the whole user bubble before Caju answers on a phone' do
    message = 'Oi Caju, ganhei R$ 120 pela Shopee e abasteci R$ 60 no Ipiranga hoje'
    parser = instance_double(Ai::ParserService)
    allow(Ai::ParserService).to receive(:new) do |messages:, **|
      received_messages << messages.last[:content]
      parser
    end
    allow(parser).to receive(:call) do
      release_answer.pop(timeout: 10)
      { type: :text, content: 'Anotado, chefe!' }
    end
    visit chat_root_path

    fill_in 'message', with: message
    find('button[type="submit"]').click

    expect(page).to have_css('#chat_typing')
    expect(page).to have_field('message', with: '')
    bubble = find('#chat_messages .bg-blue-600', text: message)
    expect(box(bubble)['right']).to be <= Phone::WIDTH
    expect(page).to have_no_text(I18n.t('chat.index.empty_title'))
    expect(page).to fit_the_phone_width
    expect(received_messages.pop(timeout: 5)).to eq(message)

    release_answer << true

    expect(page).to have_text('Anotado, chefe!')
    expect(page).to have_no_css('#chat_typing')
    expect(page.evaluate_script("document.querySelector('textarea[name=message]').readOnly")).to be(false)
    expect(page.evaluate_script('document.activeElement.name')).to eq('message')
  end
end

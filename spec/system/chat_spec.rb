require 'rails_helper'

RSpec.describe 'Chat', type: :system, js: true do
  let(:current_user) { create(:user) }
  let(:release_answer) { Queue.new }
  let(:received_messages) { Queue.new }
  let(:summary_answer) do
    {
      type:    :answer,
      content: 'profit: 1240.0, earnings: 1680.0, expenses: 440.0',
      card:    {
        kind: 'summary', year: 2026, month: 11, profit: 1240.0, earnings: 1680.0, expenses: 440.0,
        profit_change: 12.0, best_day_on: '2026-11-12', best_day_amount: 320.0
      }
    }
  end

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
    expect(mic['width']).to eq(32)
    expect(mic['height']).to eq(32)
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
    expect(page).to have_no_css('[data-message-voice]', visible: true)
    expect(page).to have_no_text(I18n.t('chat.index.empty_title'))
    expect(page).to fit_the_phone_width
    expect(received_messages.pop(timeout: 5)).to eq(message)

    release_answer << true

    expect(page).to have_text('Anotado, chefe!')
    expect(page).to have_no_css('#chat_typing')
    expect(page.evaluate_script("document.querySelector('textarea[name=message]').readOnly")).to be(false)
    expect(page.evaluate_script('document.activeElement.name')).to eq('message')
  end

  it 'shows Caju online above the message box and keeps the bubble colors in dark mode on a phone' do
    emulate_color_scheme('dark')
    parser = instance_double(Ai::ParserService)
    allow(Ai::ParserService).to receive(:new).and_return(parser)
    allow(parser).to receive(:call).and_return({ type: :text, content: 'Anotado, chefe!' })

    visit chat_root_path
    fill_in 'message', with: 'Oi Caju'
    find('button[type="submit"]').click

    expect(page).to have_css('h1', text: 'Caju')
    expect(page).to have_text(I18n.t('chat.index.subtitle'))
    expect(page).to have_css('#chat_messages .bg-blue-600', text: 'Oi Caju')
    bot_bubble = find('#chat_messages', text: 'Anotado, chefe!').find('div.bg-white')
    expect(bot_bubble.evaluate_script('getComputedStyle(this).backgroundColor')).to eq('rgb(255, 255, 255)')
    expect(page).to fit_the_phone_width
  end

  it 'centers the conversation in a narrower column on a desktop screen' do
    emulate_desktop_screen

    visit chat_root_path

    screen = find('[data-controller="chat speech"]')

    expect(box(screen)['width'].round).to eq(672)
    expect(page).to have_css('h1', text: 'Caju')
  end

  it 'cancels the first card of a batch and shows the next card on a phone' do
    allow(Llm::Client).to receive(:chat).and_return({
      type:        :tool_use,
      tool_name:   'create_earning',
      tool_input:  { 'amount' => 120, 'platform' => 'shopee', 'date' => '2026-11-16' },
      extra_calls: [{ name: 'create_expense', input: { 'amount' => 60, 'category' => 'fuel', 'vendor' => 'Ipiranga', 'date' => '2026-11-16' } }]
    })
    visit chat_root_path
    fill_in 'message', with: 'registra as corridas e o abastecimento de hoje'
    find('button[type="submit"]').click

    click_button I18n.t('chat.message.btn_cancel')

    expect(page).to have_text('Ipiranga')
    expect(page).to have_no_text(I18n.t('chat.confirm.duplicate_submit'))
    expect(page).to have_button(I18n.t('chat.message.btn_cancel'), count: 1)
    expect(page).to fit_the_phone_width
  end

  it 'draws the month summary as a card inside the Caju bubble on a phone' do
    parser = instance_double(Ai::ParserService)
    allow(Ai::ParserService).to receive(:new).and_return(parser)
    allow(parser).to receive(:call).and_return(summary_answer)
    visit chat_root_path

    fill_in 'message', with: 'Quanto lucrei esse mês?'
    find('button[type="submit"]').click

    expect(page).to have_text('você lucrou R$ 1.240,00 — 12% acima do mês anterior.')
    stats = find('#chat_messages .rounded-xl.bg-slate-50')
    expect(stats).to have_text('+R$ 1.680,00')
    expect(stats).to have_text('−R$ 440,00')
    expect(stats).to have_text('Qui · R$ 320')
    expect(page).to fit_the_phone_width

    visit chat_root_path

    expect(page).to have_css('#chat_messages .rounded-xl.bg-slate-50', text: 'Qui · R$ 320')
  end

  it 'draws the station comparison as bars on a phone' do
    parser = instance_double(Ai::ParserService)
    allow(Ai::ParserService).to receive(:new).and_return(parser)
    allow(parser).to receive(:call).and_return({
      type:    :answer,
      content: 'winner: Posto Orense, winner_kml: 11.5, runner_up: Geladão, runner_up_kml: 11.0, savings: 28',
      card:    { kind: 'vendor_efficiency', winner: 'Posto Orense', winner_kml: 11.5, runner_up: 'Geladão', runner_up_kml: 11.0, savings: 28 }
    })
    visit chat_root_path

    fill_in 'message', with: 'Qual posto compensa mais?'
    find('button[type="submit"]').click

    expect(page).to have_text('O Posto Orense tem te rendido mais: 11,5 km/L contra 11,0 do Geladão.')
    winner_bar = find('#chat_messages div.h-full.rounded-full[style*="#10b981"]')
    runner_up_bar = find('#chat_messages div.h-full.rounded-full[style*="#94a3b8"]')
    expect(box(runner_up_bar)['width']).to be < box(winner_bar)['width']
    expect(page).to have_text('Economia estimada: ~R$ 28/mês abastecendo só no Posto Orense.')
    expect(page).to fit_the_phone_width
  end

  it 'keeps the answer card inside the narrower column on a desktop screen' do
    emulate_desktop_screen
    parser = instance_double(Ai::ParserService)
    allow(Ai::ParserService).to receive(:new).and_return(parser)
    allow(parser).to receive(:call).and_return(summary_answer)
    visit chat_root_path

    fill_in 'message', with: 'Quanto lucrei esse mês?'
    find('button[type="submit"]').click

    stats = find('#chat_messages .rounded-xl.bg-slate-50', text: 'Qui · R$ 320')
    expect(box(stats)['right']).to be <= box(find('[data-controller="chat speech"]'))['right']
  end
end

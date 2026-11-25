require 'rails_helper'

RSpec.describe 'Chat voice panel', type: :system, js: true do
  let(:current_user) { create(:user) }
  let(:received_messages) { Queue.new }
  let(:parser) { instance_double(Ai::ParserService, call: { type: :text, content: 'Anotado, chefe!' }) }

  before do
    allow(Ai::ParserService).to receive(:new) do |messages:, **|
      received_messages << messages.last[:content]
      parser
    end
    install_fake_speech_recognition
    login_as(current_user)
  end

  it 'opens the voice panel before the recognition starts and waits with the hint on a phone' do
    visit chat_root_path

    find('button[aria-label="Falar"]').click

    expect(page).to have_css('[role="dialog"][aria-label="Caju ouvindo"]', visible: true)
    expect(page.evaluate_script('window.__speech.panelOpenAtStart')).to be(true)
    expect(page).to have_text('OUVINDO')
    expect(page).to have_text('Fale agora, ex.: “abasteci 80 no Orense”')
    expect(page).to have_css('[data-speech-target="timer"]', text: '0:00')
    expect(page).to have_css('[data-speech-target="wave"] span', count: 40)
    expect(page).to fit_the_phone_width
  end

  it 'shows the partial transcript live and sends the final one with a microphone bubble on a phone' do
    visit chat_root_path
    find('button[aria-label="Falar"]').click

    start_speaking
    hear('abasteci 80')

    expect(page).to have_css('[data-speech-target="transcript"]', text: 'abasteci 80')
    expect(page).to have_css('[data-speech-target="caret"]', visible: true)
    expect(page).to have_no_text('Fale agora')
    expect(page).to have_css('[data-speech-target="wave"] .bg-violet-600')

    hear('abasteci 80 no Orense', final: true)

    expect(page).to have_css('[data-speech-target="phaseLabel"].text-emerald-600', text: 'ENTENDI')
    expect(page).to have_css('[data-speech-target="checkIcon"]', visible: true)
    expect(page).to have_no_css('[role="dialog"]')
    expect(page).to have_css('#chat_messages .bg-blue-600 .text-white\/80')
    expect(page).to have_css('#chat_messages .bg-blue-600', text: 'abasteci 80 no Orense')
    expect(received_messages.pop(timeout: 5)).to eq('abasteci 80 no Orense')
    expect(page).to have_text('Anotado, chefe!')
    expect(page).to fit_the_phone_width
  end

  it 'sends the partial transcript with the send button on a phone' do
    visit chat_root_path
    find('button[aria-label="Falar"]').click
    hear('lavei o carro 30')

    click_button 'Enviar'

    expect(received_messages.pop(timeout: 5)).to eq('lavei o carro 30')
    expect(page).to have_css('#chat_messages .bg-blue-600', text: 'lavei o carro 30')
  end

  it 'discards what was heard with the trash button on a phone' do
    visit chat_root_path
    find('button[aria-label="Falar"]').click
    hear('abasteci 80')

    click_button 'Descartar'

    expect(page).to have_no_css('[role="dialog"]')
    expect(page).to have_no_css('#chat_messages .bg-blue-600')
    expect(page).to have_field('message', with: '')
    expect(Ai::ParserService).not_to have_received(:new)
  end

  it 'cancels when the dimmed background is tapped on a phone' do
    visit chat_root_path
    find('button[aria-label="Falar"]').click
    hear('abasteci 80')

    find('[data-speech-target="backdrop"]').click(x: 20, y: 20)

    expect(page).to have_no_css('[role="dialog"]')
    expect(page).to have_no_css('#chat_messages .bg-blue-600')
  end

  it 'closes the panel and warns that nothing was heard for four seconds on a phone' do
    visit chat_root_path
    find('button[aria-label="Falar"]').click

    stop_speaking

    expect(page).to have_no_css('[role="dialog"]')
    expect(page).to have_css('[role="status"]', text: 'Não ouvi nada. Toque no microfone e fale de novo.')
    expect(page).to have_no_css('#chat_messages .bg-blue-600')
    expect(page).to fit_the_phone_width
    expect(page).to have_no_css('[role="status"]', wait: 6)
  end

  it 'treats sending with nothing heard as silence on a phone' do
    visit chat_root_path
    find('button[aria-label="Falar"]').click

    click_button 'Enviar'

    expect(page).to have_css('[role="status"]', text: 'Não ouvi nada.')
    expect(Ai::ParserService).not_to have_received(:new)
  end

  it 'warns that the microphone is blocked when permission is denied on a phone' do
    visit chat_root_path
    find('button[aria-label="Falar"]').click

    fail_hearing('not-allowed')

    expect(page).to have_no_css('[role="dialog"]')
    expect(page).to have_css('[role="status"]', text: 'Microfone bloqueado. Libere nas configurações do navegador.')
  end

  it 'keeps the panel still when the phone asks for reduced motion' do
    emulate_reduced_motion('reduce')
    visit chat_root_path
    find('button[aria-label="Falar"]').click

    start_speaking

    expect(computed('[data-speech-target="sheet"]', 'transitionDuration')).to eq('0s')
    expect(computed('[data-speech-target="phaseDot"]', 'animationName')).to eq('none')
    expect(page).to have_css('[data-speech-target="wave"] .bg-violet-600')
  end
end

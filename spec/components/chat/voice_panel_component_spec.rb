require 'rails_helper'

RSpec.describe Chat::VoicePanelComponent, type: :component do
  let(:html) { view_context.render(described_class.new) }

  it 'labels the dialog and starts in the listening phase with the hint' do
    expect(html).to include('role="dialog"').and include('aria-label="Caju ouvindo"')
    expect(html).to include('>Ouvindo<')
    expect(html).to include('data-understood-label="Entendi"')
    expect(html).to include('Fale agora, ex.: “abasteci 80 no Orense”')
  end

  it 'starts the timer at 0:00 in tabular figures' do
    expect(html).to include('<span class="text-xl font-semibold tabular-nums text-slate-800 w-12 flex-shrink-0" data-speech-target="timer">0:00</span>')
  end

  it 'renders forty grey dots fading in from the left' do
    expect(html.scan('w-[3px]').size).to eq(40)
    expect(html).to include('opacity: 0.55').and include('opacity: 1.0')
    expect(html).not_to include('bg-violet-600 w-[3px]')
  end

  it 'offers discard and send buttons with the check icon waiting hidden' do
    expect(html).to include('aria-label="Descartar"').and include('aria-label="Enviar"')
    expect(html).to include('bg-red-50 text-red-500')
    expect(html).to match(/class="[^"]*hidden[^"]*"[^>]*data-speech-target="checkIcon"/)
  end

  it 'starts closed off screen and drops the motion when reduced motion is asked' do
    expect(html).to include('translate-y-[105%]').and include('invisible')
    expect(html).to include('motion-reduce:transition-none').and include('motion-reduce:animate-none')
  end
end

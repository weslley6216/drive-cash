require 'rails_helper'

RSpec.describe Chat::VoiceNoticeComponent, type: :component do
  let(:html) { view_context.render(described_class.new) }

  it 'carries both warnings for the controller to pick from' do
    expect(html).to include('data-silence="Não ouvi nada. Toque no microfone e fale de novo."')
    expect(html).to include('data-denied="Microfone bloqueado. Libere nas configurações do navegador."')
  end

  it 'waits hidden above the message box as a dark status pill' do
    expect(html).to include('role="status"')
    expect(html).to match(/class="hidden absolute left-4 right-4 bottom-full mb-3/)
    expect(html).to include('bg-slate-900 text-white text-xs font-medium')
  end
end

require 'rails_helper'

RSpec.describe NotificationPreferences::EditView, type: :component do
  let(:rows) { Notifications::PreferenceRows.call(Notifications::Preferences.new) }

  it 'lists the five kinds in registry order' do
    html = view_context.render(described_class.new(rows: rows))

    expect(html.index('Manutenção')).to be < html.index('Tanque no vermelho')
    expect(html.index('Tanque no vermelho')).to be < html.index('Meta batida')
    expect(html.index('Meta batida')).to be < html.index('Resumo semanal')
    expect(html.index('Resumo semanal')).to be < html.index('Lembrete de registrar')
  end

  it 'renders mobile and desktop headers' do
    html = view_context.render(described_class.new(rows: rows))

    expect(html).to include('Escolha o que o DriveCash te avisa')
    expect(html).to include('Escolha o que o DriveCash te avisa. Salva na hora.')
    expect(html).to include('Desligar um aviso não apaga os que já chegaram. Os avisos aparecem na central de notificações (sino).')
    expect(html).to include('Desligar um aviso não apaga os que já chegaram.')
    expect(html).to include('Conta')
    expect(html).to include('Notificações')
  end
end

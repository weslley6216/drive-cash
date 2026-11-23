require 'rails_helper'

RSpec.describe Auth::ShellComponent, type: :component do
  it 'splits the brand panel and a 384px column on the desktop' do
    html = view_context.render(described_class.new(title: 'Criar conta')) do |shell|
      shell.with_content { shell.p { 'Corpo' } }
    end

    expect(html).to include('w-[46%]')
    expect(html).to include('lg:max-w-sm')
    expect(html).to include('Corpo')
  end

  it 'shows the large brand mark above the title on the phone by default' do
    html = view_context.render(described_class.new(title: 'Criar conta', subtitle: 'Comece já.')) do |shell|
      shell.with_content { shell.p { 'Corpo' } }
    end

    expect(html).to include('w-14 h-14 rounded-2xl')
    expect(html).to include('pt-10 pb-8')
    expect(html).to include('Criar conta')
    expect(html).to include('Comece já.')
  end

  it 'swaps the brand for the back link when back: true and brand: false' do
    html = view_context.render(described_class.new(title: 'Esqueci a senha', back: true, brand: false)) do |shell|
      shell.with_content { shell.p { 'Corpo' } }
    end

    expect(html).to include(I18n.t('auth.back_to_login_component.label'))
    expect(html).to include('pt-4 pb-8')
    expect(html).not_to include('w-14 h-14 rounded-2xl')
  end

  it 'renders a desktop-only subtitle next to the phone one when desktop_subtitle is given' do
    shell_component = described_class.new(title: 'Bem-vindo', subtitle: 'No celular.', desktop_subtitle: 'No desktop.')

    html = view_context.render(shell_component) { |shell| shell.with_content { shell.p { 'Corpo' } } }

    expect(html).to include('<span class="lg:hidden">No celular.</span>')
    expect(html).to include('<span class="hidden lg:inline">No desktop.</span>')
  end

  it 'pins the footer to the bottom when one is given' do
    html = view_context.render(described_class.new(title: 'Criar conta')) do |shell|
      shell.with_content { shell.p { 'Corpo' } }
      shell.with_footer { shell.p { 'Rodapé' } }
    end

    expect(html).to include('Rodapé')
    expect(html).to include('mt-auto pt-8')
  end

  it 'renders the flash alert banner above the title' do
    view_context.flash[:alert] = 'Link inválido ou expirado.'

    html = view_context.render(described_class.new(title: 'Esqueci a senha')) do |shell|
      shell.with_content { shell.p { 'Corpo' } }
    end

    expect(html).to include('border-red-200 bg-red-50')
    expect(html).to include('Link inválido ou expirado.')
  end

  it 'renders the flash notice banner' do
    view_context.flash[:notice] = 'Senha atualizada.'

    html = view_context.render(described_class.new(title: 'Bem-vindo')) do |shell|
      shell.with_content { shell.p { 'Corpo' } }
    end

    expect(html).to include('border-green-200 bg-green-50')
    expect(html).to include('Senha atualizada.')
  end
end

require 'rails_helper'

RSpec.describe Auth::ShellComponent, type: :component do
  let(:shell_page) do
    Class.new(ApplicationComponent) do
      def initialize(with_footer: false, **options)
        @with_footer = with_footer
        @options = options
      end

      def view_template
        render Auth::ShellComponent.new(**@options) do |shell|
          shell.with_content { p { 'Corpo' } }
          shell.with_footer { p { 'Rodapé' } } if @with_footer
        end
      end
    end
  end

  def render_shell(**options)
    view_context.render(shell_page.new(**options))
  end

  it 'splits the brand panel and a 384px column on the desktop' do
    html = render_shell(title: 'Criar conta')

    expect(html).to include('w-[46%]')
    expect(html).to include('lg:max-w-sm')
    expect(html).to include('Corpo')
  end

  it 'shows the large brand mark above the title on the phone by default' do
    html = render_shell(title: 'Criar conta', subtitle: 'Comece já.')

    expect(html).to include('w-14 h-14 rounded-2xl')
    expect(html).to include('pt-10 pb-8')
    expect(html).to include('Criar conta')
    expect(html).to include('Comece já.')
  end

  it 'swaps the brand for the back link when back: true and brand: false' do
    html = render_shell(title: 'Esqueci a senha', back: true, brand: false)

    expect(html).to include(I18n.t('auth.back_to_login_component.label'))
    expect(html).to include('pt-4 pb-8')
    expect(html).not_to include('w-14 h-14 rounded-2xl')
  end

  it 'renders a desktop-only subtitle next to the phone one when desktop_subtitle is given' do
    html = render_shell(title: 'Bem-vindo', subtitle: 'No celular.', desktop_subtitle: 'No desktop.')

    expect(html).to include('<span class="lg:hidden">No celular.</span>')
    expect(html).to include('<span class="hidden lg:inline">No desktop.</span>')
  end

  it 'pins the footer to the bottom when one is given' do
    html = render_shell(title: 'Criar conta', with_footer: true)

    expect(html).to include('Rodapé')
    expect(html).to include('mt-auto pt-8')
  end

  it 'renders the flash alert banner above the title' do
    view_context.flash[:alert] = 'Link inválido ou expirado.'

    html = render_shell(title: 'Esqueci a senha')

    expect(html).to include('border-red-200 bg-red-50')
    expect(html).to include('Link inválido ou expirado.')
  end

  it 'renders the flash notice banner' do
    view_context.flash[:notice] = 'Senha atualizada.'

    html = render_shell(title: 'Bem-vindo')

    expect(html).to include('border-green-200 bg-green-50')
    expect(html).to include('Senha atualizada.')
  end
end

require 'rails_helper'

RSpec.describe Auth::PasswordFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(:user, User.new, view_context, {}) }

  def render_field(**options, &)
    view_context.render(
      described_class.new(form: form, attribute: :password, label: 'Senha', autocomplete: 'new-password', **options), &
    )
  end

  it 'renders a lock icon, the password input and a 44px eye toggle' do
    html = render_field

    expect(html).to include(PhlexIcons::Lucide::Lock.new(class: 'w-[18px] h-[18px]').call)
    expect(html).to include('type="password"')
    expect(html).to include('pl-11 pr-11 py-3')
    expect(html).to include('data-controller="password-toggle"')
    expect(html).to include("aria-label=\"#{I18n.t('auth.password_field_component.show')}\"")
    expect(html).to include('absolute right-1 top-1/2 -translate-y-1/2 w-11 h-11')
  end

  it 'shows the hint below the field' do
    html = render_field(hint: 'Mínimo de 8 caracteres.')

    expect(html).to include('<p class="text-xs text-slate-500 mt-1.5">Mínimo de 8 caracteres.</p>')
  end

  it 'replaces the hint with the red error and red border when an error is given' do
    html = render_field(hint: 'Mínimo de 8 caracteres.', error: 'As senhas não são iguais.')

    expect(html).to include('border-red-300 ring-2 ring-red-100 focus:ring-red-200')
    expect(html).to include('As senhas não são iguais.')
    expect(html).not_to include('Mínimo de 8 caracteres.')
  end

  it 'puts the given block on the label row' do
    html = render_field { 'Esqueci a senha' }

    expect(html).to include('flex items-center justify-between mb-1.5')
    expect(html).to include('Esqueci a senha')
  end
end

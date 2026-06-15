require 'rails_helper'

RSpec.describe ConfirmActionComponent, type: :component do
  let(:html) do
    view_context.render(
      described_class.new(
        title:          'Excluir receita?',
        icon:           PhlexIcons::Lucide::Trash2,
        confirm_path:   '/earnings/1',
        confirm_method: :delete,
        confirm_label:  'Excluir receita',
        cancel_label:   'Cancelar'
      )
    )
  end

  it 'scopes content under the confirm-action Stimulus controller' do
    expect(html).to include('data-controller="confirm-action"')
  end

  it 'renders the overlay hidden by default' do
    expect(html).to include('data-confirm-action-target="overlay"')
    expect(html).to match(/hidden[^"]*"[^>]*data-confirm-action-target="overlay"|data-confirm-action-target="overlay"[^>]*class="[^"]*hidden/)
  end

  it 'renders the title in both mobile and desktop variants' do
    expect(html.scan('Excluir receita?').size).to eq 2
  end

  it 'renders a mobile bottom sheet with handle bar' do
    expect(html).to include('lg:hidden')
    expect(html).to include('rounded-t-3xl')
  end

  it 'renders a desktop centered modal' do
    expect(html).to include('lg:flex')
    expect(html).to include('rounded-2xl')
  end

  it 'renders a dismiss action for the backdrop click' do
    expect(html).to include('confirm-action#dismiss')
  end

  it 'renders the cancel button in both variants' do
    expect(html.scan('Cancelar').size).to eq 2
  end

  it 'renders a form submitting to the confirm path' do
    expect(html).to include('action="/earnings/1"')
    expect(html).to include('_method" value="delete"')
  end

  it 'renders the confirm label on the submit button in both variants' do
    expect(html.scan('Excluir receita').size).to be >= 2
  end

  context 'when description is provided' do
    let(:html) do
      view_context.render(
        described_class.new(
          title:          'Sair da conta?',
          icon:           PhlexIcons::Lucide::LogOut,
          confirm_path:   '/session',
          confirm_method: :delete,
          confirm_label:  'Sim, sair',
          cancel_label:   'Cancelar',
          description:    'Você será desconectado.'
        )
      )
    end

    it 'renders the description in both variants' do
      expect(html.scan('Você será desconectado.').size).to eq 2
    end
  end

  context 'when icon_theme is :blue' do
    let(:html) do
      view_context.render(
        described_class.new(
          title:          'Confirmação',
          icon:           PhlexIcons::Lucide::Info,
          confirm_path:   '/something',
          confirm_method: :delete,
          confirm_label:  'Confirmar',
          cancel_label:   'Cancelar',
          icon_theme:     :blue
        )
      )
    end

    it 'applies blue icon theme' do
      expect(html).to include('bg-blue-50')
      expect(html).to include('text-blue-600')
    end
  end

  context 'when icon_theme is not recognized' do
    let(:html) do
      view_context.render(
        described_class.new(
          title:          'Confirmação',
          icon:           PhlexIcons::Lucide::Info,
          confirm_path:   '/something',
          confirm_method: :delete,
          confirm_label:  'Confirmar',
          cancel_label:   'Cancelar',
          icon_theme:     :green
        )
      )
    end

    it 'falls back to slate icon theme' do
      expect(html).to include('bg-slate-100')
      expect(html).to include('text-slate-600')
    end
  end

  it 'renders the desktop backdrop with bg-black/30' do
    expect(html).to include('bg-black/30')
  end

  it 'renders the desktop confirm button with the icon' do
    expect(html).to include('w-4 h-4')
  end

  context 'when confirm_method is :post' do
    let(:html) do
      view_context.render(
        described_class.new(
          title:          'Confirmar',
          icon:           PhlexIcons::Lucide::Check,
          confirm_path:   '/something',
          confirm_method: :post,
          confirm_label:  'Confirmar',
          cancel_label:   'Cancelar'
        )
      )
    end

    it 'does not render any _method hidden input' do
      expect(html).not_to include('name="_method"')
    end
  end

  context 'when turbo is disabled' do
    let(:html) do
      view_context.render(
        described_class.new(
          title:          'Sair da conta?',
          icon:           PhlexIcons::Lucide::LogOut,
          confirm_path:   '/session',
          confirm_method: :delete,
          confirm_label:  'Sim, sair',
          cancel_label:   'Cancelar',
          turbo:          false
        )
      )
    end

    it 'disables turbo on the confirm form' do
      expect(html).to include('data-turbo="false"')
    end
  end
end

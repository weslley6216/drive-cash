require 'rails_helper'

RSpec.describe Auth::CtaComponent, type: :component do
  it 'renders a submit button with the arrow icon by default' do
    html = view_context.render(described_class.new(label: 'Criar conta'))

    expect(html).to include('type="submit"')
    expect(html).to include('w-full bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-3.5 lg:py-3 text-sm font-semibold shadow-lg shadow-blue-600/25')
    expect(html).to include(PhlexIcons::Lucide::ArrowRight.new(class: 'w-4 h-4 stroke-[2.4]').call)
  end

  it 'renders the given icon' do
    html = view_context.render(described_class.new(label: 'Enviar link', icon: PhlexIcons::Lucide::Send))

    expect(html).to include(PhlexIcons::Lucide::Send.new(class: 'w-4 h-4 stroke-[2.4]').call)
  end

  it 'renders a link without icon when href is given and icon is nil' do
    html = view_context.render(described_class.new(label: 'Voltar para Entrar', icon: nil, href: '/session/new'))

    expect(html).to include('<a')
    expect(html).to include('href="/session/new"')
    expect(html).not_to include('<svg')
  end
end

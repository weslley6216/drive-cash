require 'rails_helper'

RSpec.describe EmptyStateComponent, type: :component do
  let(:default_props) do
    {
      icon:        PhlexIcons::Lucide::Receipt,
      title:       'Ainda sem lançamentos',
      description: 'Registre o primeiro ganho ou gasto.',
      cta_label:   'Registrar o primeiro',
      cta_path:    '/earnings/new',
      cta_icon:    PhlexIcons::Lucide::Plus
    }
  end

  def render_component(**overrides)
    view_context.render(described_class.new(**default_props.merge(overrides)))
  end

  it 'renders the title and the description' do
    html = render_component

    expect(html).to include('Ainda sem lançamentos')
    expect(html).to include('Registre o primeiro ganho ou gasto.')
  end

  it 'renders the CTA pointing to the given path' do
    html = render_component

    expect(html).to include('Registrar o primeiro')
    expect(html).to include('href="/earnings/new"')
  end

  it 'falls back to the slate ring and icon colour' do
    html = render_component

    expect(html).to include('bg-slate-100 border-slate-200')
    expect(html).to include('text-slate-400')
  end

  it 'applies the ring and icon colour when given' do
    html = render_component(ring: 'bg-blue-50 border-blue-100', icon_color: 'text-blue-600')

    expect(html).to include('bg-blue-50 border-blue-100')
    expect(html).to include('text-blue-600')
  end

  it 'forwards data attributes to the CTA' do
    html = render_component(cta_data: { turbo_frame: 'modal' })

    expect(html).to include('data-turbo-frame="modal"')
  end

  it 'renders the secondary link when a label is given' do
    html = render_component(secondary_label: 'Ou fale com o Caju', secondary_path: '/chat')

    expect(html).to include('Ou fale com o Caju')
    expect(html).to include('href="/chat"')
  end

  it 'renders no secondary link when no label is given' do
    html = render_component

    expect(html).not_to include('text-xs font-semibold text-blue-600')
  end
end

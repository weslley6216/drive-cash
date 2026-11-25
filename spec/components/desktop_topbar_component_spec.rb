require 'rails_helper'

RSpec.describe DesktopTopbarComponent, type: :component do
  let(:html) do
    view_context.render(described_class.new(title: 'Análise', subtitle: 'Maio de 2026', unread_count: 2)) do |topbar|
      topbar.with_actions { topbar.button { 'Exportar' } }
    end
  end

  it 'renders the white desktop-only bar bleeding to the sidebar' do
    header = Nokogiri::HTML5.fragment(html).at_css('header')

    expect(header['class']).to eq('hidden lg:flex -mx-8 bg-white border-b border-slate-200 px-8 py-4 items-center justify-between gap-6')
  end

  it 'renders the title and the subtitle with the prototype type scale' do
    expect(html).to include('<div class="min-w-0"><h1 class="text-2xl font-bold text-slate-900 tracking-tight">Análise</h1>' \
                            '<p class="text-sm text-slate-500 mt-0.5">Maio de 2026</p></div>')
  end

  it 'puts the back link to the parent screen above the title' do
    html = view_context.render(described_class.new(title: 'Movimentação do tanque', subtitle: 'Abastecimentos',
                                                   unread_count: 0, back: { label: 'Meu veículo', path: '/vehicle' }))

    title_block = Nokogiri::HTML5.fragment(html).at_css('header > div.min-w-0')
    back = title_block.element_children.first

    expect(title_block.element_children.map(&:name)).to eq(%w[a h1 p])
    expect(back['href']).to eq('/vehicle')
    expect(back['class']).to eq('flex items-center gap-1 text-xs font-semibold text-slate-500 hover:text-slate-800 mb-1')
    expect(back.text).to eq('Meu veículo')
    expect(back.at_css('svg')['class']).to eq('w-3.5 h-3.5')
  end

  it 'lines the actions up on the right with the bell as the last item' do
    actions = Nokogiri::HTML5.fragment(html).at_css('header > div:last-child')

    expect(actions['class']).to eq('flex items-center gap-3 flex-shrink-0')
    expect(actions.element_children.map(&:name)).to eq(%w[button span a])
    expect(actions.element_children.last['href']).to eq('/notifications')
  end

  it 'separates the actions from the bell with a divider' do
    expect(html).to include('<span class="w-px h-6 bg-slate-200"></span>')
  end

  it 'drops the divider when the screen has no actions' do
    bare = view_context.render(described_class.new(title: 'Análise', subtitle: 'Maio de 2026', unread_count: 2))

    actions = Nokogiri::HTML5.fragment(bare).at_css('header > div:last-child')

    expect(actions.element_children.map(&:name)).to eq(%w[a])
    expect(actions.to_html).not_to include('w-px h-6 bg-slate-200')
  end

  it 'hands the unread count to the bell' do
    expect(html).to include('aria-label="Notificações, 2 não lidas"')
  end

  it 'activates the bell on the notification center' do
    active = view_context.render(described_class.new(title: 'Análise', subtitle: 'Maio de 2026', unread_count: 2, bell_active: true))

    expect(active).to include('bg-blue-50 text-blue-700')
    expect(active).to include('aria-current="page"')
  end
end

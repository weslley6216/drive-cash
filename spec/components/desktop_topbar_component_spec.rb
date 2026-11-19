require 'rails_helper'

RSpec.describe DesktopTopbarComponent, type: :component do
  let(:topbar_page) do
    Class.new(ApplicationComponent) do
      def initialize(with_actions:, **options)
        @with_actions = with_actions
        @options = options
      end

      def view_template
        render DesktopTopbarComponent.new(**@options) do |topbar|
          topbar.with_actions { button { 'Exportar' } } if @with_actions
        end
      end
    end
  end

  def render_topbar(with_actions: true, **options)
    view_context.render(topbar_page.new(with_actions: with_actions, title: 'Análise', subtitle: 'Maio de 2026',
                                        unread_count: 2, **options))
  end

  def actions_of(html)
    Nokogiri::HTML5.fragment(html).at_css('header > div:last-child')
  end

  it 'renders the white desktop-only bar bleeding to the sidebar' do
    header = Nokogiri::HTML5.fragment(render_topbar).at_css('header')

    expect(header['class']).to eq('hidden lg:flex -mx-8 bg-white border-b border-slate-200 px-8 py-4 items-center justify-between gap-6')
  end

  it 'renders the title and the subtitle with the prototype type scale' do
    html = render_topbar

    expect(html).to include('<div class="min-w-0"><h1 class="text-2xl font-bold text-slate-900 tracking-tight">Análise</h1>' \
                            '<p class="text-sm text-slate-500 mt-0.5">Maio de 2026</p></div>')
  end

  it 'lines the actions up on the right with the bell as the last item' do
    actions = actions_of(render_topbar)

    expect(actions['class']).to eq('flex items-center gap-3 flex-shrink-0')
    expect(actions.element_children.map(&:name)).to eq(%w[button span a])
    expect(actions.element_children.last['href']).to eq('/notifications')
  end

  it 'separates the actions from the bell with a divider' do
    expect(render_topbar).to include('<span class="w-px h-6 bg-slate-200"></span>')
  end

  it 'drops the divider when the screen has no actions' do
    actions = actions_of(render_topbar(with_actions: false))

    expect(actions.element_children.map(&:name)).to eq(%w[a])
    expect(actions.to_html).not_to include('w-px h-6 bg-slate-200')
  end

  it 'hands the unread count to the bell' do
    expect(render_topbar).to include('aria-label="Notificações, 2 não lidas"')
  end

  it 'activates the bell on the notification center' do
    html = render_topbar(bell_active: true)

    expect(html).to include('bg-blue-50 text-blue-700')
    expect(html).to include('aria-current="page"')
  end
end

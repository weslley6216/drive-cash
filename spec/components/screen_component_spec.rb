require 'rails_helper'

RSpec.describe ScreenComponent, type: :component do
  let(:screen_page) do
    Class.new(ApplicationComponent) do
      def initialize(with_header: true, **options)
        @with_header = with_header
        @options = options
      end

      def view_template
        render ScreenComponent.new(**@options) do |screen|
          screen.with_header { h1 { 'Topo' } } if @with_header
          screen.with_content { p { 'Corpo' } }
        end
      end
    end
  end

  def render_screen(**options)
    view_context.render(screen_page.new(**options))
  end

  it 'pins the header outside the content that scrolls' do
    html = render_screen

    expect(html).to include('<div id="screen-header" class="flex-none"><h1>Topo</h1></div>')
    expect(html).to include('<div id="screen-content" class="flex-1 min-h-0 overflow-y-auto px-5 sm:px-6 pb-24 lg:px-0 lg:pb-8 lg:pt-8"><p>Corpo</p></div>')
  end

  it 'pads the phone top past the status bar in a full-height column' do
    expect(render_screen).to include('<div class="flex-1 flex flex-col min-h-0 safe-top sm:pt-0">')
  end

  it 'keeps the flash outside the content that scrolls' do
    expect(render_screen).to include('<div id="flash" class="flex-none">')
  end

  it 'gives the page a single flash id for the turbo streams to update while a toast shows' do
    view_context.flash[:notice] = 'Salvo!'

    html = render_screen

    expect(html.scan('id="flash"').size).to eq(1)
    expect(html).to include('Salvo!')
  end

  it 'leaves the header wrapper out when the screen has no header' do
    expect(render_screen(with_header: false)).not_to include('screen-header')
  end

  it 'leaves the desktop top gutter to the header when the header sits inline on desktop' do
    expect(render_screen(inline_header: true)).to include('class="flex-1 min-h-0 overflow-y-auto px-5 sm:px-6 pb-24 lg:px-0 lg:pb-8"')
  end

  it 'wraps the screen in the page frame with the loading overlay over the content' do
    html = render_screen(frame: true)

    expect(html).to include('<turbo-frame')
    expect(html).to include('id="page"')
    expect(html).to include('flex-1 flex flex-col min-h-0 safe-top sm:pt-0')
    expect(html).to include('<div class="feed-loading-region flex-1 flex flex-col min-h-0"><div class="feed-loading-overlay">')
  end

  it 'renders the screen without the page frame by default' do
    expect(render_screen).not_to include('id="page"')
  end
end

require 'rails_helper'

RSpec.describe DesktopBellComponent, type: :component do
  it 'links to the notification center escaping the page frame' do
    html = view_context.render(described_class.new(unread_count: 0))

    expect(html).to include('href="/notifications"')
    expect(html).to include('data-turbo-frame="_top"')
  end

  it 'renders the square slate button with the 20px bell from the prototype' do
    html = view_context.render(described_class.new(unread_count: 0))

    expect(html).to include('relative w-10 h-10 rounded-lg flex items-center justify-center text-slate-600 hover:bg-slate-50')
    expect(Nokogiri::HTML5.fragment(html).at_css('a svg')['class']).to eq('w-5 h-5')
    expect(html).not_to include('aria-current')
  end

  it 'shows the red badge with the raw unread count over the bell corner' do
    html = view_context.render(described_class.new(unread_count: 12))

    expect(html).to include('<span class="absolute top-1.5 right-1.5 min-w-[16px] h-4 px-1 rounded-full bg-red-500 ' \
                            'text-white text-[10px] font-bold leading-4 text-center ring-2 ring-white">12</span>')
  end

  it 'omits the badge without unread notifications' do
    html = view_context.render(described_class.new(unread_count: 0))

    expect(html).not_to include('bg-red-500')
  end

  it 'labels the bell with the unread count' do
    expect(view_context.render(described_class.new(unread_count: 3))).to include('aria-label="Notificações, 3 não lidas"')
    expect(view_context.render(described_class.new(unread_count: 1))).to include('aria-label="Notificações, 1 não lida"')
  end

  it 'labels the bell plainly without unread notifications' do
    expect(view_context.render(described_class.new(unread_count: 0))).to include('aria-label="Notificações"')
  end

  context 'when active on the notification center' do
    let(:html) { view_context.render(described_class.new(unread_count: 3, active: true)) }

    it 'highlights the bell in blue as the current page' do
      expect(html).to include('relative w-10 h-10 rounded-lg flex items-center justify-center bg-blue-50 text-blue-700')
      expect(html).to include('aria-current="page"')
    end

    it 'hides the badge' do
      expect(html).not_to include('bg-red-500')
    end
  end
end

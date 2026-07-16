require 'rails_helper'

RSpec.describe NotificationBellComponent, type: :component do
  it 'links to the notification center' do
    html = view_context.render(described_class.new(unread_count: 0))

    expect(html).to include('href="/notifications"')
  end

  it 'renders the unread count badge' do
    html = view_context.render(described_class.new(unread_count: 3))

    expect(html).to include('rounded-full bg-blue-600')
    expect(html).to include('>3<')
  end

  it 'omits the badge when there are no unread notifications' do
    html = view_context.render(described_class.new(unread_count: 0))

    expect(html).not_to include('rounded-full bg-blue-600')
  end
end

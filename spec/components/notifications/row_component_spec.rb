require 'rails_helper'

RSpec.describe Notifications::RowComponent, type: :component do
  let(:user) { create(:user) }

  def render_row(notification, bucket: :today, last: false)
    row = Notifications::Presenters.present(notification)
    view_context.render(described_class.new(row: row, bucket: bucket, last: last))
  end

  it 'highlights an unread row with a blue tint, bold title and a dot' do
    notification = create(:notification, user: user, kind: 'tank_low', data: { 'status' => 'negative' })

    html = render_row(notification)

    expect(html).to include('bg-blue-50/40')
    expect(html).to include('font-bold')
    expect(html).to include('w-2 h-2 rounded-full bg-blue-600')
  end

  it 'renders a read row without the tint, dot or bold title' do
    notification = create(:notification, user: user, kind: 'tank_low',
                                         data: { 'status' => 'negative' }, read_at: Time.current)

    html = render_row(notification)

    expect(html).not_to include('bg-blue-50/40')
    expect(html).not_to include('w-2 h-2 rounded-full bg-blue-600')
    expect(html).to include('font-medium')
  end

  it 'paints the icon tile with the palette of the notification kind' do
    notification = create(:notification, user: user, kind: 'tank_low', data: { 'status' => 'negative' })

    html = render_row(notification)

    expect(html).to include('bg-red-50')
    expect(html).to include('text-red-600')
  end

  it 'submits a PATCH to the read route' do
    notification = create(:notification, user: user)

    html = render_row(notification)

    expect(html).to include("action=\"/notifications/#{notification.id}/read\"")
    expect(html).to include('name="_method" value="patch"')
  end

  it 'formats the timestamp as a clock time in the today bucket' do
    notification = create(:notification, user: user, created_at: Time.zone.local(2026, 7, 14, 9, 12))

    html = render_row(notification, bucket: :today)

    expect(html).to include('09:12')
  end

  it 'formats the timestamp as weekday and time in the week bucket' do
    notification = create(:notification, user: user, created_at: Time.zone.local(2026, 7, 8, 18, 5))

    html = render_row(notification, bucket: :week)

    expect(html).to include('qua · 18:05')
  end

  it 'formats the timestamp as day and short month in the earlier bucket' do
    notification = create(:notification, user: user, created_at: Time.zone.local(2026, 7, 4, 8, 0))

    html = render_row(notification, bucket: :earlier)

    expect(html).to include('04/jul')
  end

  it 'draws a bottom border on every row but the last' do
    notification = create(:notification, user: user)

    expect(render_row(notification, last: false)).to include('border-b border-slate-100')
    expect(render_row(notification, last: true)).not_to include('border-b border-slate-100')
  end
end

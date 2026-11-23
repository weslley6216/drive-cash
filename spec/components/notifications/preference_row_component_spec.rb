require 'rails_helper'

RSpec.describe Notifications::PreferenceRowComponent, type: :component do
  let(:enabled_row) do
    Notifications::PreferenceRows::Row.new(kind: 'tank_low', title: 'Tanque no vermelho', rule: 'Regra do tanque',
                                           icon: PhlexIcons::Lucide::Fuel, palette_key: :danger, enabled: true)
  end
  let(:disabled_row) { enabled_row.with(enabled: false) }

  it 'renders a checked toggle for an enabled kind' do
    html = view_context.render(described_class.new(row: enabled_row, first: true))

    expect(html).to include('checked class="sr-only peer"')
    expect(html).to include('text-slate-800')
  end

  it 'renders an unchecked dimmed toggle for a disabled kind' do
    html = view_context.render(described_class.new(row: disabled_row, first: true))

    expect(html).not_to include('checked class="sr-only peer"')
    expect(html).to include('text-slate-500')
    expect(html).to include('opacity-50')
  end

  it 'submits kind and enabled to the preferences endpoint on change' do
    html = view_context.render(described_class.new(row: enabled_row, first: true))

    expect(html).to include('action="/notification_preferences"')
    expect(html).to include('value="patch"')
    expect(html).to include('name="kind"')
    expect(html).to include('change->auto-submit#submit')
  end

  it 'shows a focus ring on the toggle track for keyboard users' do
    html = view_context.render(described_class.new(row: enabled_row, first: true))

    expect(html).to include('peer-focus-visible:ring-2')
  end

  it 'separates rows after the first' do
    expect(view_context.render(described_class.new(row: enabled_row, first: true))).not_to include('border-t border-slate-100')
    expect(view_context.render(described_class.new(row: enabled_row, first: false))).to include('border-t border-slate-100')
  end
end

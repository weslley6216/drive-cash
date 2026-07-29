require 'rails_helper'

RSpec.describe Exports::CreateView, type: :view do
  let(:export) { create(:export, status: 'pending') }

  it 'prepends the new row to the recents list' do
    html = render(described_class.new(export: export))

    expect(html).to include('action="prepend"')
    expect(html).to include('target="export-recents"')
    expect(html).to include(%(id="export_#{export.id}"))
  end

  it 'drops the empty state so the new row is alone in the card' do
    html = render(described_class.new(export: export))

    expect(html).to include('action="remove"')
    expect(html).to include('target="export-recents-empty"')
  end

  it 'installs the wait slot that holds the loading overlay' do
    html = render(described_class.new(export: export))

    expect(html).to include('action="replace"')
    expect(html).to include('target="export-wait"')
    expect(html).to include('data-controller="export-wait"')
  end
end

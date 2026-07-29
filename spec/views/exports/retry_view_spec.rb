require 'rails_helper'

RSpec.describe Exports::RetryView, type: :view do
  let(:export) { create(:export, status: 'pending') }

  it 'replaces the frame element itself, not only its children' do
    html = render(described_class.new(export: export))

    expect(html).to include('action="replace"')
    expect(html).to include(%(target="export_#{export.id}"))
  end

  it 'carries the polling attributes the requeued row needs' do
    html = render(described_class.new(export: export))

    expect(html).to include('data-controller="export-row-poll"')
    expect(html).to include(%(data-export-row-poll-export-id-value="#{export.id}"))
  end
end

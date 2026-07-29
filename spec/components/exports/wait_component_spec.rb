require 'rails_helper'

RSpec.describe Exports::WaitComponent, type: :component do
  let(:export) { create(:export, status: 'pending') }

  it 'mounts the wait controller for the export just submitted' do
    html = view_context.render(described_class.new(export: export))

    expect(html).to include('id="export-wait"')
    expect(html).to include('data-controller="export-wait"')
    expect(html).to include(%(data-export-wait-export-id-value="#{export.id}"))
  end

  it 'releases the screen after the escape timeout' do
    html = view_context.render(described_class.new(export: export))

    expect(html).to include(%(data-export-wait-timeout-value="#{described_class::TIMEOUT_MS}"))
  end

  it 'stays out of the cached snapshot so going back does not hold the screen again' do
    html = view_context.render(described_class.new(export: export))

    expect(html).to include('data-turbo-temporary')
  end

  it 'carries a hidden download link so the file can be fetched without a second click' do
    html = view_context.render(described_class.new(export: export))

    expect(html).to include(%(href="/exports/#{export.id}"))
    expect(html).to include('data-export-wait-target="download"')
    expect(html).to include('data-turbo="false"')
  end

  it 'hands the time expectation to the overlay that holds the screen' do
    html = view_context.render(described_class.new(export: export))

    expect(html).to include(%(data-export-wait-message-value="#{I18n.t('exports.async_hint')}"))
  end

  it 'carries the long wait hint hidden until the escape fires' do
    html = view_context.render(described_class.new(export: export))

    expect(html).to include(I18n.t('exports.wait.still_running'))
    expect(html).to match(/class="hidden [^"]*"[^>]*data-export-wait-target="hint"/)
  end
end

require 'rails_helper'

RSpec.describe Exports::RecentRowView, type: :view do
  let(:user) { create(:user) }

  it 'wraps the row in a turbo frame per export' do
    export = create(:export, user: user, period_kind: 'year', period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))

    html = render(described_class.new(export: export))

    expect(html).to include(%(id="export_#{export.id}"))
    expect(html).to include('Ano de 2026')
  end

  it 'separates the queued state from the generating state' do
    queued = render(described_class.new(export: create(:export, user: user, status: 'pending')))
    generating = render(described_class.new(export: create(:export, user: user, status: 'processing')))

    expect(queued).to include(I18n.t('exports.status.pending'))
    expect(generating).to include(I18n.t('exports.status.processing'))
    expect(queued).not_to include(I18n.t('exports.status.processing'))
  end

  it 'keeps polling with a window derived from the stale limit while the export is running' do
    export = create(:export, user: user, status: 'processing')
    window = Exports::PollWindow.new

    html = render(described_class.new(export: export))

    expect(html).to include('export-row-poll')
    expect(html).to include(%(data-export-row-poll-interval-value="#{window.interval_ms}"))
    expect(html).to include(%(data-export-row-poll-max-attempts-value="#{window.max_attempts}"))
    expect(html).to include(%(data-export-row-poll-export-id-value="#{export.id}"))
  end

  it 'announces the terminal status on the settled element so the client can react to it' do
    export = create(:export, user: user, status: 'done')

    html = render(described_class.new(export: export))

    expect(html).to include('data-export-row-poll-target="settled"')
    expect(html).to include('data-export-status="done"')
  end

  it 'announces a failed export as settled too' do
    export = create(:export, user: user, status: 'failed')

    html = render(described_class.new(export: export))

    expect(html).to include('data-export-row-poll-target="settled"')
    expect(html).to include('data-export-status="failed"')
  end

  it 'stops polling once the export settled' do
    html = render(described_class.new(export: create(:export, user: user, status: 'done')))

    expect(html).not_to include('data-controller="export-row-poll"')
  end

  it 'shows the human size when the file is attached' do
    export = create(:export, user: user, status: 'done')
    export.file.attach(io: StringIO.new('x' * 2048), filename: 'r.csv', content_type: 'text/csv')

    html = render(described_class.new(export: export))

    expect(html).to include('2 KB')
  end

  it 'bypasses turbo on the download link so the browser downloads the file' do
    export = create(:export, user: user, status: 'done')
    export.file.attach(io: StringIO.new('x'), filename: 'r.csv', content_type: 'text/csv')

    html = render(described_class.new(export: export))

    expect(html).to include(%(href="/exports/#{export.id}"))
    expect(html).to include('data-turbo="false"')
  end

  it 'hides the download link when the export failed' do
    export = create(:export, user: user, status: 'failed')

    html = render(described_class.new(export: export))

    expect(html).to include(I18n.t('exports.status.failed'))
    expect(html).not_to include(%(href="/exports/#{export.id}"))
  end

  it 'keeps the download link off a row that is still being generated' do
    export = create(:export, user: user, status: 'processing')

    html = render(described_class.new(export: export))

    expect(html).to include(I18n.t('exports.status.processing'))
    expect(html).not_to include(%(href="/exports/#{export.id}"))
  end

  it 'marks a row that is still being generated with a clock' do
    queued = render(described_class.new(export: create(:export, user: user, status: 'pending')))
    ready = render(described_class.new(export: create(:export, user: user, status: 'done')))
    clock = render(PhlexIcons::Lucide::Clock.new(class: 'w-[18px] h-[18px]'))

    expect(queued).to include(clock)
    expect(ready).not_to include(clock)
  end

  it 'offers a retry on the failed row' do
    export = create(:export, user: user, status: 'failed')

    html = render(described_class.new(export: export))

    expect(html).to include(%(action="/exports/#{export.id}/retry"))
    expect(html).to include(I18n.t('exports.retry'))
  end

  it 'keeps the retry out of a finished row' do
    export = create(:export, user: user, status: 'done')

    html = render(described_class.new(export: export))

    expect(html).not_to include(I18n.t('exports.retry'))
  end

  it 'draws the separator on the frame so the last row has none' do
    html = render(described_class.new(export: create(:export, user: user)))

    expect(html).to include('border-b border-slate-100 last:border-b-0')
  end
end

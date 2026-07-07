require 'rails_helper'

RSpec.describe Exports::RecentRowView, type: :view do
  let(:user) { create(:user) }

  it 'wraps the row in a turbo frame per export' do
    export = create(:export, user: user, period_kind: 'year', period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))

    html = render(described_class.new(export: export, last: true))

    expect(html).to include(%(id="export_#{export.id}"))
    expect(html).to include('Ano de 2026')
  end

  it 'shows the generating hint when the export is not done' do
    export = create(:export, user: user, status: 'processing')

    html = render(described_class.new(export: export, last: true))

    expect(html).to include(I18n.t('exports.flash.not_ready'))
  end

  it 'shows the human size when the file is attached' do
    export = create(:export, user: user, status: 'done')
    export.file.attach(io: StringIO.new('x' * 2048), filename: 'r.csv', content_type: 'text/csv')

    html = render(described_class.new(export: export, last: true))

    expect(html).to include('2 KB')
  end

  it 'stops polling and hides the download link when the export failed' do
    export = create(:export, user: user, status: 'failed')

    html = render(described_class.new(export: export, last: true))

    expect(html).to include(I18n.t('exports.flash.failed'))
    expect(html).not_to include('export-row-poll')
    expect(html).not_to include(%(href="/exports/#{export.id}"))
  end
end

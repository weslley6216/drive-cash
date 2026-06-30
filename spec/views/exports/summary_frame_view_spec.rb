require 'rails_helper'

RSpec.describe Exports::SummaryFrameView, type: :view do
  let(:payload) do
    Exports::Builder::Payload.new(
      earnings:     [],
      expenses:     [],
      refuelings:   [],
      maintenances: [],
      totals:       { earnings: BigDecimal('29530.70'), expenses: BigDecimal('12975.43'), profit: BigDecimal('16555.27'), count: 328 }
    )
  end

  it 'renders the five summary rows with localized labels' do
    html = render(described_class.new(payload: payload, period_label: 'Jan–Jun 2026', format: 'pdf'))

    expect(html).to include('Período')
    expect(html).to include('Jan–Jun 2026')
    expect(html).to include('328')
    expect(html).to include('R$ 29.530,70')
    expect(html).to include('R$ 12.975,43')
    expect(html).to include('R$ 16.555,27')
  end

  it 'applies the design colors to earnings, expenses and profit' do
    html = render(described_class.new(payload: payload, period_label: 'Jan–Jun 2026', format: 'pdf'))

    expect(html).to include('text-emerald-700')
    expect(html).to include('text-red-700')
    expect(html).to include('text-blue-700')
  end

  it 'shows a format-aware CTA' do
    html = render(described_class.new(payload: payload, period_label: 'Jan–Jun 2026', format: 'csv'))

    expect(html).to include(I18n.t('exports.cta_format.csv'))
  end

  it 'is wrapped in the export-summary turbo frame' do
    html = render(described_class.new(payload: payload, period_label: 'Jan–Jun 2026', format: 'pdf'))

    expect(html).to include('id="export-summary"')
  end
end

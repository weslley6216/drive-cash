require 'rails_helper'

RSpec.describe History::PeriodSummaryComponent, type: :component do
  let(:summary) { { earnings: 1200.0, expenses: 450.0, net: 750.0 } }
  let(:html)    { view_context.render(described_class.new(summary: summary)) }

  it 'renders the three card labels from i18n' do
    expect(html).to include(I18n.t('history.index.summary.earnings'))
    expect(html).to include(I18n.t('history.index.summary.expenses'))
    expect(html).to include(I18n.t('history.index.summary.net'))
  end

  it 'renders formatted currency values' do
    expect(html).to include('1.200,00')
    expect(html).to include('450,00')
    expect(html).to include('750,00')
  end

  it 'uses green styling for earnings card' do
    expect(html).to include('bg-green-50')
    expect(html).to include('border-green-200')
  end

  it 'uses red styling for expenses card' do
    expect(html).to include('bg-red-50')
    expect(html).to include('border-red-200')
  end

  it 'uses blue styling for net card' do
    expect(html).to include('bg-blue-50')
    expect(html).to include('border-blue-200')
  end

  it 'lays out the three cards in a 3-column grid' do
    expect(html).to include('grid-cols-3')
  end

  it 'uses compact value size to prevent overflow in the 3-column layout' do
    expect(html).to include('text-sm')
  end
end

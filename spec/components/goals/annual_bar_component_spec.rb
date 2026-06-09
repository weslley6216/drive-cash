require 'rails_helper'

RSpec.describe Goals::AnnualBarComponent, type: :component do
  let(:progress) do
    { current: 20_000, target: 80_000, percent: 25, days_remaining: 199 }
  end
  let(:html) { view_context.render(described_class.new(progress: progress)) }

  it 'renders a horizontal bar with width matching percent' do
    expect(html).to include('width: 25%')
  end

  it 'shows current and target formatted in BRL' do
    expect(html).to include('R$ 20.000,00')
    expect(html).to include('R$ 80.000,00')
  end

  it 'shows remaining months derived from days_remaining' do
    expected_months = (199 / 30.0).round
    expect(html).to include(I18n.t('goals.index.annual.remaining_months', count: expected_months))
  end

  it 'clamps the bar width when percent exceeds 100' do
    output = view_context.render(described_class.new(progress: progress.merge(percent: 120)))

    expect(output).to include('width: 100%')
  end
end

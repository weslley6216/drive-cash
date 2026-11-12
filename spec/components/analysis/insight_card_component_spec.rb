require 'rails_helper'

RSpec.describe Analysis::InsightCardComponent, type: :component do
  let(:insight) do
    {
      type:        'category_spike',
      severity:    'warning',
      title:       'Combustível subiu 15%',
      description: 'Você gastou R$ 600,00 em Combustível.'
    }
  end
  let(:html) { view_context.render(Analysis::InsightCardComponent.new(insight: insight)) }

  it 'renders the insight title and description' do
    expect(html).to include('Combustível subiu 15%')
    expect(html).to include('Você gastou R$ 600,00 em Combustível.')
  end

  it 'always uses amber palette regardless of severity' do
    expect(html).to include('bg-amber-50')
    expect(html).to include('border-amber-200')

    critical = view_context.render(
      Analysis::InsightCardComponent.new(insight: insight.merge(severity: 'critical'))
    )

    expect(critical).to include('bg-amber-50')
    expect(critical).not_to include('bg-red-50')
  end

  it 'renders the flame icon in an amber rounded bubble' do
    expect(html).to include('bg-amber-400/30')
    expect(html).to include('rounded-full')
    expect(html).to include('text-amber-600')
  end

  it 'uses amber text colors for title and description' do
    expect(html).to include('text-amber-900')
    expect(html).to include('text-amber-800')
  end

  it 'grows into the desktop insight card of the prototype' do
    html = view_context.render(described_class.new(insight: { title: 'T', description: 'D' }))

    expect(html).to include('rounded-2xl lg:rounded-xl bg-amber-50 border border-amber-200 p-4 lg:p-5 flex items-start gap-3 lg:gap-4')
    expect(html).to include('w-9 h-9 lg:w-11 lg:h-11')
    expect(html).to include('text-xs lg:text-sm text-amber-800 mt-0.5 lg:mt-1 leading-relaxed')
  end
end

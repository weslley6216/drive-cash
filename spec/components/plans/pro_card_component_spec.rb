require 'rails_helper'

RSpec.describe Plans::ProCardComponent, type: :component do
  subject(:html) { view_context.render(described_class.new(comparison: Plans::Comparison.new)) }

  it 'highlights the pro plan as recommended' do
    expect(html).to include(I18n.t('plans.pro_card.recommended'))
    expect(html).to include(I18n.t('plans.names.pro'))
    expect(html).to include('border-blue-600')
  end

  it 'renders the yearly price visible and the monthly price hidden' do
    expect(html).to include('R$ 11,92')
    expect(html).to include('R$ 14,90')
    expect(html).to match(/hidden[^>]*data-plan-billing-target="monthlyPrice"/)
  end

  it 'states how the yearly plan is charged' do
    expect(html).to include(I18n.t('plans.pro_card.charged_yearly', price: 'R$ 143,00'))
    expect(html).to include(I18n.t('plans.pro_card.charged_monthly'))
  end

  it 'lists every pro benefit' do
    expect(html).to include(I18n.t('plans.features.exports'))
    expect(html).to include(I18n.t('plans.features.backup'))
  end

  it 'submits the subscribe cta as a patch to the plan' do
    expect(html).to include(I18n.t('plans.pro_card.cta'))
    expect(html).to include('data-turbo-method="patch"')
    expect(html).to include('href="/plan"')
  end
end

require 'rails_helper'

RSpec.describe Plans::FreeCardComponent, type: :component do
  it 'renders the free plan with a zero price and muted benefits' do
    html = view_context.render(described_class.new(comparison: Plans::Comparison.new))

    expect(html).to include(I18n.t('plans.names.free'))
    expect(html).to include(I18n.t('plans.free_card.badge'))
    expect(html).to include(I18n.t('plans.free_card.forever'))
    expect(html).to include('R$ 0')
    expect(html).to include(I18n.t('plans.features.records'))
    expect(html).to include('text-slate-400')
  end
end

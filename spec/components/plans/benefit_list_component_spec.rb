require 'rails_helper'

RSpec.describe Plans::BenefitListComponent, type: :component do
  it 'renders one checked item per feature key' do
    html = view_context.render(described_class.new(features: %i[exports caju]))

    expect(html).to include(I18n.t('plans.features.exports'))
    expect(html).to include(I18n.t('plans.features.caju'))
    expect(html.scan('<li').size).to eq(2)
  end

  it 'paints the benefits in emerald by default' do
    html = view_context.render(described_class.new(features: %i[exports]))

    expect(html).to include('text-emerald-500')
    expect(html).to include('text-slate-700')
  end

  it 'mutes the benefits when asked' do
    html = view_context.render(described_class.new(features: %i[records], muted: true))

    expect(html).to include('text-slate-400')
    expect(html).to include('text-slate-500')
    expect(html).not_to include('text-emerald-500')
  end
end

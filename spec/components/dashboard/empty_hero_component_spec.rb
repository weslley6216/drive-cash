require 'rails_helper'

RSpec.describe Dashboard::EmptyHeroComponent, type: :component do
  it 'renders the dashed placeholder for the given year' do
    html = view_context.render(described_class.new(year: 2026))

    expect(html).to include('border-dashed')
    expect(html).to include(I18n.t('empty_states.home.hero_label', year: 2026))
    expect(html).to include(I18n.t('empty_states.home.hero_placeholder'))
  end
end

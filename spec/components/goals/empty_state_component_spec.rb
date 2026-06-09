require 'rails_helper'

RSpec.describe Goals::EmptyStateComponent, type: :component do
  let(:html) { view_context.render(described_class.new) }

  it 'renders the empty title' do
    expect(html).to include(I18n.t('goals.index.empty.title'))
  end

  it 'renders the CTA button linking to new goal modal' do
    expect(html).to include(I18n.t('goals.index.empty.cta'))
    expect(html).to include('href="/goals/new"')
    expect(html).to include('data-turbo-frame="modal"')
  end
end

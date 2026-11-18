require 'rails_helper'

RSpec.describe History::LoadMoreComponent, type: :component do
  let(:html) { view_context.render(described_class.new(path: '/history?page=2')) }
  let(:link) { Capybara.string(html).find('a', text: I18n.t('history.index.load_more')) }

  it 'links to the given page' do
    expect(link[:href]).to eq('/history?page=2')
  end

  it 'swaps only the feed frame and advances the address' do
    expect(link['data-turbo-frame']).to eq('history-feed')
    expect(link['data-turbo-action']).to eq('advance')
  end

  it 'uses the full-width outlined button of the design' do
    expect(link[:class]).to include('w-full py-3 text-sm font-medium text-blue-600 border border-slate-200 bg-white rounded-xl')
  end
end

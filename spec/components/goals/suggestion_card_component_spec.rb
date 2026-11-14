require 'rails_helper'

RSpec.describe Goals::SuggestionCardComponent, type: :component do
  let(:html) { view_context.render(described_class.new(amount: BigDecimal('6200'))) }

  it 'renders the suggestion label' do
    expect(html).to include(I18n.t('goals.index.suggestion.label'))
  end

  it 'highlights the formatted amount inside the sentence' do
    expect(html).to include(I18n.t('goals.index.suggestion.text_before'))
    expect(html).to include('<span class="font-bold text-slate-800">R$ 6.200,00</span>')
  end

  it 'uses the padded card surface from the prototype' do
    expect(html).to include('bg-white rounded-xl shadow-sm border border-slate-100 p-4')
  end
end

require 'rails_helper'

RSpec.describe BackLinkComponent, type: :component do
  it 'renders the prototype arrow left linking to the fallback when the screen opened directly' do
    html = view_context.render(described_class.new(fallback: '/account', label: 'Voltar'))

    link = Nokogiri::HTML5.fragment(html).at_css('a')

    expect(link['href']).to eq('/account')
    expect(link['class']).to eq('p-1 -ml-1 mt-0.5 text-slate-500')
    expect(link['aria-label']).to eq('Voltar')
    expect(link.at_css('svg')['class']).to eq('w-[22px] h-[22px]')
  end
end

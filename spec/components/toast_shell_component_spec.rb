require 'rails_helper'

RSpec.describe ToastShellComponent, type: :component do
  it 'wraps the content in the fixed dark toast' do
    html = view_context.render(described_class.new) { 'conteudo-do-bloco' }

    expect(html).to include('bg-slate-900')
    expect(html).to include('bottom-above-nav')
    expect(html).to include('data-flash-delay-value="6000"')
    expect(html).to include('conteudo-do-bloco')
  end
end

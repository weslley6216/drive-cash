require 'rails_helper'

RSpec.describe Auth::OrDividerComponent, type: :component do
  it 'renders the "ou" between two rules' do
    html = view_context.render(described_class.new)

    expect(html).to include('flex items-center gap-3 py-1')
    expect(html).to include('<span class="text-xs text-slate-400">ou</span>')
  end
end

require 'rails_helper'

RSpec.describe Notifications::MutedToastComponent, type: :component do
  it 'names the muted kind and offers to undo' do
    html = view_context.render(described_class.new(payload: { 'kind' => 'log_reminder' }))

    expect(html).to include('Você não vai mais receber “Lembrete de registrar”.')
    expect(html).to include('name="enabled" value="true"')
    expect(html).to include('name="kind" value="log_reminder"')
    expect(html).to include('bg-slate-900')
    expect(html).to include('data-flash-delay-value="6000"')
  end
end

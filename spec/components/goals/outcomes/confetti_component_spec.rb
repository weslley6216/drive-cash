require 'rails_helper'

RSpec.describe Goals::Outcomes::ConfettiComponent, type: :component do
  let(:confetti) { Capybara.string(view_context.render(described_class.new)) }

  it 'drops 42 pieces on a phone and 64 on a desktop screen' do
    expect(confetti).to have_css('.dc-confetti[aria-hidden="true"] i', count: 64, visible: :all)
    expect(confetti).to have_css('.dc-confetti i.hidden.lg\:block', count: 22, visible: :all)
  end

  it 'gives every piece its own fall in the prototype palette' do
    first_piece = confetti.first('.dc-confetti i', visible: :all)

    expect(first_piece[:style]).to include('--dur:').and include('--delay:').and include('--dx:').and include('--rot:')
    expect(first_piece[:style]).to include('background: #10b981')
  end

  it 'draws the same pieces on every render' do
    expect(view_context.render(described_class.new)).to eq(view_context.render(described_class.new))
  end
end

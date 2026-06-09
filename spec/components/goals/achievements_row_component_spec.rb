require 'rails_helper'

RSpec.describe Goals::AchievementsRowComponent, type: :component do
  let(:achievements) do
    [
      { icon: 'flame', label: 'Sequência 7 dias', color: '#f97316' },
      { icon: 'trophy', label: 'Meta semanal batida', color: '#22c55e' },
      { icon: 'star', label: 'Melhor dia: R$ 800,00', color: '#eab308' }
    ]
  end
  let(:html) { view_context.render(described_class.new(achievements: achievements)) }

  it 'renders the achievements title' do
    expect(html).to include(I18n.t('goals.index.achievements.title'))
  end

  it 'renders one badge per achievement with its label' do
    expect(html).to include('Sequência 7 dias')
    expect(html).to include('Meta semanal batida')
    expect(html).to include('Melhor dia: R$ 800,00')
  end

  it 'applies the given color inline' do
    expect(html).to include('background-color: #f97316')
    expect(html).to include('background-color: #22c55e')
  end

  it 'renders an empty wrapper when no achievements are provided' do
    output = view_context.render(described_class.new(achievements: []))

    expect(output).to include(I18n.t('goals.index.achievements.title'))
    expect(output.scan('rounded-full').size).to eq(0)
  end
end

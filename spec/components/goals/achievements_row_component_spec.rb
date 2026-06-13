require 'rails_helper'

RSpec.describe Goals::AchievementsRowComponent, type: :component do
  let(:achievements) do
    [
      { type: :streak, label: 'Sequência 7 dias' },
      { type: :goal_completed, label: 'Meta mensal batida' },
      { type: :best_day, label: 'Melhor dia: R$ 800,00', value: 800 }
    ]
  end
  let(:html) { view_context.render(described_class.new(achievements: achievements)) }

  it 'renders the achievements title' do
    expect(html).to include(I18n.t('goals.index.achievements.title'))
  end

  it 'renders one item per achievement with its label' do
    expect(html).to include('Sequência 7 dias')
    expect(html).to include('Meta mensal batida')
    expect(html).to include('Melhor dia: R$ 800,00')
  end

  it 'maps each badge type to its palette color via inline style' do
    expect(html).to include('background-color: #f97316')
    expect(html).to include('background-color: #a855f7')
    expect(html).to include('background-color: #3b82f6')
  end

  it 'renders icon circles with rounded-full' do
    expect(html.scan('rounded-full').size).to eq(achievements.size)
  end

  it 'falls back to the default palette when the badge type is unknown' do
    unknown = [{ type: :something_new, label: 'Teste' }]
    output = view_context.render(described_class.new(achievements: unknown))

    expect(output).to include('Teste')
    expect(output).to include('background-color: #64748b')
  end

  it 'renders an empty message when no achievements are provided' do
    output = view_context.render(described_class.new(achievements: []))

    expect(output).to include(I18n.t('goals.index.achievements.title'))
    expect(output).to include(I18n.t('goals.index.achievements.empty'))
    expect(output.scan('rounded-full').size).to eq(0)
  end
end

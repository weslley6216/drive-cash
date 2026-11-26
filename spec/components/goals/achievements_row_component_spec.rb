require 'rails_helper'

RSpec.describe Goals::AchievementsRowComponent, type: :component do
  let(:achievements) do
    [
      { type: :streak, days: 7 },
      { type: :goal_completed, period_start: Date.new(2026, 4, 1), percent: 108 },
      { type: :best_day, value: 3000.70, date: Date.new(2026, 5, 2) }
    ]
  end
  let(:html) { view_context.render(described_class.new(achievements: achievements)) }

  it 'renders the achievements title' do
    expect(html).to include(I18n.t('goals.index.achievements.title'))
  end

  it 'renders the short label for the phone and hides it from the desktop breakpoint' do
    expect(html).to include('<span class="lg:hidden">Sequência 7 dias</span>')
    expect(html).to include('<span class="lg:hidden">Meta de Abril</span>')
    expect(html).to include("<span class=\"lg:hidden\">Melhor dia: R$\u00A03.001</span>")
  end

  it 'renders the long label only from the desktop breakpoint' do
    expect(html).to include('<span class="hidden lg:inline">Sequência de 7 dias trabalhando</span>')
    expect(html).to include('<span class="hidden lg:inline">Meta de Abril batida (108%)</span>')
    expect(html).to include("<span class=\"hidden lg:inline\">Melhor dia: R$\u00A03.001 em 02/mai</span>")
  end

  it 'maps each badge type to its palette color via inline style' do
    expect(html).to include('background-color: #f97316')
    expect(html).to include('background-color: #a855f7')
    expect(html).to include('background-color: #3b82f6')
  end

  it 'renders icon circles with rounded-full' do
    expect(html.scan('rounded-full').size).to eq(achievements.size)
  end

  it 'renders an empty message when no achievements are provided' do
    output = view_context.render(described_class.new(achievements: []))

    expect(output).to include(I18n.t('goals.index.achievements.title'))
    expect(output).to include(I18n.t('goals.index.achievements.empty'))
    expect(output.scan('rounded-full').size).to eq(0)
  end
end

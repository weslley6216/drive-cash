require 'rails_helper'

RSpec.describe Goals::Outcomes::ShowView, type: :component do
  let(:goal) do
    build_stubbed(:goal, kind: 'monthly', metric: 'profit', target_amount: 6_000,
                         period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
  end
  let(:outcome) do
    Goals::Outcomes::Hit::Result.new(
      goal:            goal,
      target:          goal.target_amount,
      achieved:        BigDecimal('6120'),
      percent:         BigDecimal('102'),
      surplus:         BigDecimal('120'),
      hit_on:          Date.new(2026, 6, 27),
      days_before_end: 3,
      worked_days:     21,
      per_day:         BigDecimal('291.43'),
      best_day:        Goals::Outcomes::Base::BestDay.new(date: Date.new(2026, 6, 13), value: BigDecimal('412')),
      streak:          2,
      next_period:     Date.new(2026, 7, 1)..Date.new(2026, 7, 31),
      next_goal:       nil,
      suggestion:      6_500
    )
  end

  def render_view(outcome_data = outcome, confetti: false)
    view_context.render(described_class.new(outcome: outcome_data, confetti: confetti))
  end

  it 'celebrates the hit goal with the result, the surplus and the hit day' do
    html = render_view

    expect(html).to include('Meta mensal · lucro líquido')
    expect(html).to include('Meta de junho batida!')
    expect(html).to include('Você fez <strong class="text-slate-900">R$ 6.120,00</strong> de lucro líquido em junho.')
    expect(html).to include('+R$ 120,00 acima da meta · 102%')
    expect(html).to include('Batida em').and include('27/jun').and include('3 dias antes do fim')
  end

  it 'tells a goal hit on its last day' do
    html = render_view(outcome.with(days_before_end: 0))

    expect(html).to include('no último dia')
  end

  it 'heads the screen with the period and links back to the notifications and over to the goals' do
    html = render_view

    expect(html).to include('Meta batida').and include('Junho · 2026')
    expect(html).to include('Junho · 2026 · meta mensal de lucro líquido')
    expect(html).to include('href="/notifications"')
    expect(html).to include('Ver metas').and include('Ver todas as metas')
  end

  it 'explains how the goal was reached with the worked days, the pace and the best day' do
    html = render_view

    expect(html).to include('Como você chegou lá')
    expect(html).to include('Dias rodados').and include('21')
    expect(html).to include('Lucro / dia').and include('R$ 291,43')
    expect(html).to include('Melhor dia').and include('R$ 412,00').and include('sáb, 13/jun')
  end

  it 'shows the streak line from two periods in a row' do
    html = render_view

    expect(html).to include('2 meses seguidos batendo a meta')
  end

  it 'leaves the streak line out for a single period' do
    html = render_view(outcome.with(streak: 1))

    expect(html).not_to include('seguidos batendo a meta')
  end

  it 'words the streak of a weekly goal in weeks' do
    weekly_goal = build_stubbed(:goal, kind: 'weekly', metric: 'profit', target_amount: 6_000,
                                       period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))

    html = render_view(outcome.with(goal: weekly_goal, streak: 3,
                                    next_period: Date.new(2026, 7, 13)..Date.new(2026, 7, 19)))

    expect(html).to include('3 semanas seguidas batendo a meta')
  end

  it 'labels an earnings goal by its gross earnings' do
    earnings_goal = build_stubbed(:goal, kind: 'monthly', metric: 'earnings', target_amount: 6_000,
                                         period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

    html = render_view(outcome.with(goal: earnings_goal))

    expect(html).to include('Meta mensal · ganhos').and include('Ganho / dia')
  end

  it 'suggests the next target with the per day pace in the same worked days' do
    html = render_view

    expect(html).to include('Que tal R$ 6.500,00 em julho?')
    expect(html).to include('É o seu resultado de junho com 5% a mais, arredondado. ' \
                            'Dá R$ 309,52 por dia no mesmo ritmo de dias.')
  end

  it 'posts raise and keep to the goals create with the next period' do
    page_html = Capybara.string(render_view)

    expect(page_html).to have_css('form[action="/goals"][method="post"]', count: 2)
    expect(page_html).to have_button('Subir a meta')
    expect(page_html).to have_button('Manter R$ 6.000')
    expect(page_html).to have_css('input[type=hidden][name="goal[target_amount]"][value="6500"]', visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[target_amount]"][value="6000.0"]', visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[period_start]"][value="2026-07-01"]', count: 2, visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[period_end]"][value="2026-07-31"]', count: 2, visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[kind]"][value="monthly"]', count: 2, visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[metric]"][value="profit"]', count: 2, visible: :all)
  end

  it 'shows only the link to the next goal when it already exists' do
    july = build_stubbed(:goal, kind: 'monthly', period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))

    page_html = Capybara.string(render_view(outcome.with(next_goal: july)))

    expect(page_html).to have_link('Ver meta de julho', href: '/goals?month=7&year=2026')
    expect(page_html).to have_no_button('Subir a meta')
    expect(page_html).to have_no_text('Que tal')
  end

  it 'links the next weekly goal to the goals list' do
    weekly_goal = build_stubbed(:goal, kind: 'weekly', metric: 'profit', target_amount: 6_000,
                                       period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
    next_week = build_stubbed(:goal, kind: 'weekly', period_start: Date.new(2026, 7, 13),
                                     period_end: Date.new(2026, 7, 19))

    page_html = Capybara.string(render_view(outcome.with(goal: weekly_goal, next_goal: next_week,
                                                         next_period: Date.new(2026, 7, 13)..Date.new(2026, 7, 19))))

    expect(page_html).to have_link('Ver meta de 13/jul a 19/jul', href: '/goals')
  end

  it 'leaves the next step out when the next period has ended' do
    html = render_view(outcome.with(next_period: nil))

    expect(html).not_to include('Próximo passo')
    expect(render_view).to include('Próximo passo')
  end

  it 'throws the confetti only when asked to' do
    expect(render_view(confetti: true)).to include('dc-confetti')
    expect(render_view(confetti: false)).not_to include('dc-confetti')
  end

  it 'renders the missed screen for a missed outcome' do
    weekly_goal = build_stubbed(:goal, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                                       period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
    missed = Goals::Outcomes::Missed::Result.new(
      goal: weekly_goal, target: weekly_goal.target_amount, achieved: BigDecimal('990'), percent: 90,
      shortfall: BigDecimal('110'), near: true, worked_days: 4, per_day: BigDecimal('247.5'),
      best_day: Goals::Outcomes::Base::BestDay.new(date: Date.new(2026, 7, 10), value: BigDecimal('270')),
      track_record: nil, next_period: nil, next_goal: nil, adjusted_target: nil, work_days: 4,
      per_work_day: BigDecimal('275')
    )

    html = render_view(missed)

    expect(html).to include('Resultado da meta').and include('Não foi dessa vez, mas foi perto')
    expect(html).not_to include('Meta batida')
    expect(render_view).to include('Meta batida')
  end
end

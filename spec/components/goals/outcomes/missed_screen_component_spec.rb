require 'rails_helper'

RSpec.describe Goals::Outcomes::MissedScreenComponent, type: :component do
  let(:goal) do
    build_stubbed(:goal, kind: 'weekly', metric: 'profit', target_amount: 1_100,
                         period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))
  end
  let(:outcome) do
    Goals::Outcomes::Missed::Result.new(
      goal:            goal,
      target:          goal.target_amount,
      achieved:        BigDecimal('990'),
      percent:         90,
      shortfall:       BigDecimal('110'),
      near:            true,
      worked_days:     4,
      per_day:         BigDecimal('247.5'),
      best_day:        Goals::Outcomes::Base::BestDay.new(date: Date.new(2026, 7, 10), value: BigDecimal('270')),
      track_record:    Goals::TrackRecord::Result.new(hits: 3, total: 4),
      next_period:     Date.new(2026, 7, 13)..Date.new(2026, 7, 19),
      next_goal:       nil,
      adjusted_target: 1_050,
      work_days:       4,
      per_work_day:    BigDecimal('275')
    )
  end

  before { travel_to Time.zone.local(2026, 7, 13, 9, 0) }

  def render_screen(outcome_data = outcome)
    view_context.render(described_class.new(outcome: outcome_data))
  end

  it 'heads the screen as the goal result with the period and links back to the notifications' do
    html = render_screen

    expect(html).to include('Resultado da meta').and include('06/jul a 12/jul · 2026')
    expect(html).to include('06/jul a 12/jul · 2026 · meta semanal de lucro líquido')
    expect(html).to include('href="/notifications"')
  end

  it 'tells how close the result came with the amber ring and the shortfall' do
    html = render_screen

    expect(html).to include('stroke="#f59e0b"').and include('>90<span').and include('da meta')
    expect(html).to include('Meta semanal · lucro líquido')
    expect(html).to include('Não foi dessa vez, mas foi perto')
    expect(html).to include('Na semana de 06/jul a 12/jul você fez <strong class="text-slate-900">R$ 990,00</strong>. ' \
                            'Faltaram <strong class="text-slate-900">R$ 110,00</strong> para os R$ 1.100,00.')
    expect(html).to include('Faltaram').and include('text-amber-700')
  end

  it 'drops the near wording under eighty percent' do
    html = render_screen(outcome.with(near: false, percent: 63))

    expect(html).to include('Não foi dessa vez')
    expect(html).not_to include('mas foi perto')
  end

  it 'shows no confetti and no red, only the amber tone' do
    html = render_screen

    expect(html).to include('text-amber-700')
    expect(html).not_to include('dc-confetti')
    expect(html).not_to match(/(bg|text|border)-red-\d/)
  end

  it 'tells what went well with the pace and the track record' do
    html = render_screen

    expect(html).to include('O que foi bem')
    expect(html).to include('Dias rodados').and include('Lucro / dia').and include('R$ 247,50')
    expect(html).to include('Melhor dia').and include('R$ 270,00').and include('sex, 10/jul')
    expect(html).to include('Você bateu 3 das últimas 4 metas semanais.')
  end

  it 'leaves the track record line out when it is not favorable' do
    html = render_screen(outcome.with(track_record: nil))

    expect(html).not_to include('Você bateu')
    expect(render_screen).to include('Você bateu')
  end

  it 'keeps the target within reach for this week with the per day pace' do
    html = render_screen

    expect(html).to include('R$ 1.100,00 continua ao seu alcance')
    expect(html).to include('Para esta semana: R$ 275,00 por dia em 4 dias de trabalho. ' \
                            'Se a semana for mais curta, ajuste a meta sem culpa.')
  end

  it 'names the next period when it is not the current one' do
    html = render_screen(outcome.with(next_period: Date.new(2026, 7, 20)..Date.new(2026, 7, 26)))

    expect(html).to include('Para 20/jul a 26/jul:')
  end

  it 'posts keep and adjust to the goals create with the next period' do
    page_html = Capybara.string(render_screen)

    expect(page_html).to have_css('form[action="/goals"][method="post"]', count: 2)
    expect(page_html).to have_button('Manter a meta')
    expect(page_html).to have_button('Ajustar para R$ 1.050')
    expect(page_html).to have_css('input[type=hidden][name="goal[target_amount]"][value="1100.0"]', visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[target_amount]"][value="1050"]', visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[period_start]"][value="2026-07-13"]', count: 2, visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[period_end]"][value="2026-07-19"]', count: 2, visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[kind]"][value="weekly"]', count: 2, visible: :all)
    expect(page_html).to have_css('input[type=hidden][name="goal[metric]"][value="profit"]', count: 2, visible: :all)
  end

  it 'keeps a single keep button without an adjustment' do
    page_html = Capybara.string(render_screen(outcome.with(adjusted_target: nil)))

    expect(page_html).to have_css('div.grid-cols-1 button', text: 'Manter a meta')
    expect(page_html).to have_no_button(/Ajustar para/)
  end

  it 'shows only the link to the next goal when it already exists' do
    next_week = build_stubbed(:goal, kind: 'weekly', period_start: Date.new(2026, 7, 13),
                                     period_end: Date.new(2026, 7, 19))

    page_html = Capybara.string(render_screen(outcome.with(next_goal: next_week)))

    expect(page_html).to have_link('Ver meta de 13/jul a 19/jul', href: '/goals')
    expect(page_html).to have_no_button('Manter a meta')
    expect(page_html).to have_no_text('continua ao seu alcance')
  end

  it 'leaves the next step out when the next period has ended' do
    html = render_screen(outcome.with(next_period: nil))

    expect(html).not_to include('Próximo passo')
    expect(render_screen).to include('Próximo passo')
  end

  it 'links to the entries of the week from the top bar and the footer' do
    page_html = Capybara.string(render_screen)

    expect(page_html).to have_link('Ver lançamentos da semana', href: '/history?focus_day=2026-07-06', count: 2)
  end

  it 'links a monthly goal to its month and an annual goal to its year in the history' do
    monthly_goal = build_stubbed(:goal, kind: 'monthly', metric: 'profit', target_amount: 1_100,
                                        period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
    annual_goal = build_stubbed(:goal, kind: 'annual', metric: 'profit', target_amount: 1_100,
                                       period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))

    monthly_html = Capybara.string(render_screen(outcome.with(goal: monthly_goal, next_period: nil)))
    annual_html = Capybara.string(render_screen(outcome.with(goal: annual_goal, next_period: nil)))

    expect(monthly_html).to have_link('Ver lançamentos do mês', href: '/history?month=6&year=2026', count: 2)
    expect(monthly_html).to have_text('Em junho você fez')
    expect(annual_html).to have_link('Ver lançamentos do ano', href: '/history?year=2026', count: 2)
  end

  it 'labels an earnings goal by its gross earnings' do
    earnings_goal = build_stubbed(:goal, kind: 'weekly', metric: 'earnings', target_amount: 1_100,
                                         period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))

    html = render_screen(outcome.with(goal: earnings_goal))

    expect(html).to include('Meta semanal · ganhos').and include('Ganho / dia')
  end
end

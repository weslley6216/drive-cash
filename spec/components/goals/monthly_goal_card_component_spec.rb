require 'rails_helper'

RSpec.describe Goals::MonthlyGoalCardComponent, type: :component do
  let(:goal) do
    build_stubbed(:goal,
                  kind:          'monthly',
                  target_amount: 6000,
                  period_start:  Date.new(2026, 6, 1),
                  period_end:    Date.new(2026, 6, 30))
  end
  let(:progress) do
    {
      goal:              goal,
      current:           1500,
      target:            6000,
      percent:           25,
      projection:        3000,
      on_track:          false,
      reached:           false,
      tracking:          false,
      surplus:           0,
      daily_pace:        100,
      remaining_per_day: 300,
      days_remaining:    15
    }
  end

  context 'default :compact variant' do
    let(:html) { view_context.render(described_class.new(progress: progress)) }

    it 'renders card with blue border highlight' do
      expect(html).to include('border-2 border-blue-200')
    end

    it 'renders ProgressRing with 120px size' do
      expect(html).to include('width="120" height="120"')
    end

    it 'renders the three labelled metrics with dividers' do
      expect(html).to include(I18n.t('goals.index.monthly.remaining'))
      expect(html).to include(I18n.t('goals.index.monthly.per_day'))
      expect(html).to include(I18n.t('goals.index.monthly.current_pace'))
      expect(html).to include('border-x border-slate-100')
    end

    it 'shows current/target formatted in BRL' do
      expect(html).to include('R$ 1.500,00')
      expect(html).to include('R$ 6.000,00')
    end

    it 'shows at_risk projection badge when on_track is false' do
      expect(html).to include(I18n.t('goals.index.monthly.at_risk_projection', value: 'R$ 3.000,00'))
      expect(html).to include('bg-amber-50')
    end

    it 'shows days_left' do
      expect(html).to include(I18n.t('goals.index.monthly.days_left', count: 15))
    end

    it 'shows the month name from period_start' do
      expect(html).to include(I18n.l(goal.period_start, format: '%B'))
    end
  end

  context 'with :wide variant (desktop hero)' do
    let(:html) do
      view_context.render(described_class.new(progress: progress, variant: :wide))
    end

    it 'renders ProgressRing with 200px size' do
      expect(html).to include('width="200" height="200"')
    end

    it 'uses 3-column grid layout' do
      expect(html).to include('grid-cols-12')
    end
  end

  context 'on_track projection' do
    it 'shows on_track badge with emerald colors when projection meets target' do
      good = progress.merge(projection: 7000, on_track: true)
      html = view_context.render(described_class.new(progress: good))

      expect(html).to include(I18n.t('goals.index.monthly.on_track_projection', value: 'R$ 7.000,00'))
      expect(html).to include('bg-emerald-50')
    end
  end

  context 'when reached' do
    let(:reached_progress) do
      progress.merge(reached: true, surplus: 57.08, on_track: true,
                     remaining_per_day: 0, current: 5057.08)
    end

    it 'shows the reached badge with surplus and emerald colors' do
      html = view_context.render(described_class.new(progress: reached_progress))

      expect(html).to include(I18n.t('goals.index.monthly.reached', surplus: 'R$ 57,08'))
      expect(html).to include('bg-emerald-50')
    end

    it 'omits the projection text when reached' do
      html = view_context.render(described_class.new(progress: reached_progress))

      expect(html).not_to include(I18n.t('goals.index.monthly.on_track_projection', value: 'R$ 3.000,00'))
    end
  end

  context 'when tracking (insufficient days)' do
    let(:tracking_progress) { progress.merge(tracking: true, projection: nil) }

    it 'shows the tracking placeholder' do
      html = view_context.render(described_class.new(progress: tracking_progress))

      expect(html).to include(I18n.t('goals.index.monthly.tracking'))
    end
  end

  context 'when the period has ended without reaching the goal' do
    let(:ended_progress) { progress.merge(ended: true, reached: false) }

    it 'shows the missed badge with the shortfall instead of a projection' do
      html = view_context.render(described_class.new(progress: ended_progress))

      expect(html).to include(I18n.t('goals.index.monthly.missed', shortfall: 'R$ 4.500,00'))
      expect(html).not_to include(I18n.t('goals.index.monthly.at_risk_projection', value: 'R$ 3.000,00'))
    end

    it 'omits the days remaining countdown' do
      html = view_context.render(described_class.new(progress: ended_progress))

      expect(html).not_to include(I18n.t('goals.index.monthly.days_left', count: 15))
    end
  end

  it 'uses daily_pace for the current_pace metric' do
    html = view_context.render(described_class.new(progress: progress))

    expect(html).to include('R$ 100,00')
  end

  context 'edit pencil' do
    let(:active_goal) do
      build_stubbed(:goal, kind:         'monthly',
                           period_start: Date.current.beginning_of_month,
                           period_end:   Date.current.end_of_month)
    end
    let(:ended_goal) do
      build_stubbed(:goal, kind:         'monthly',
                           period_start: Date.current.prev_month.beginning_of_month,
                           period_end:   Date.current.prev_month.end_of_month)
    end

    it 'renders the edit link when the goal is active' do
      html = view_context.render(described_class.new(progress: progress.merge(goal: active_goal)))

      expect(html).to include("href=\"#{view_context.edit_goal_path(active_goal)}\"")
      expect(html).to include('turbo-frame="modal"')
    end

    it 'hides the edit link when the goal has ended' do
      html = view_context.render(described_class.new(progress: progress.merge(goal: ended_goal)))

      expect(html).not_to include("href=\"#{view_context.edit_goal_path(ended_goal)}\"")
      expect(html).not_to include('turbo-frame="modal"')
    end
  end
end

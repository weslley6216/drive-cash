require 'rails_helper'

RSpec.describe Goals::MonthlyGoalCardComponent, type: :component do
  let(:goal) do
    build_stubbed(:goal,
                  kind: 'monthly',
                  target_amount: 6000,
                  period_start: Date.new(2026, 6, 1),
                  period_end: Date.new(2026, 6, 30))
  end
  let(:progress) do
    {
      goal: goal,
      current: 1500,
      target: 6000,
      percent: 25,
      projection: 3000,
      on_track: false,
      remaining_per_day: 300,
      days_remaining: 15
    }
  end

  context 'default :compact variant' do
    let(:html) { view_context.render(described_class.new(progress: progress)) }

    it 'renders ProgressRing with 120px size' do
      expect(html).to include('width="120" height="120"')
    end

    it 'renders the three labelled metrics' do
      expect(html).to include(I18n.t('goals.index.monthly.remaining'))
      expect(html).to include(I18n.t('goals.index.monthly.per_day'))
      expect(html).to include(I18n.t('goals.index.monthly.current_pace'))
    end

    it 'shows current/target formatted in BRL' do
      expect(html).to include('R$ 1.500,00')
      expect(html).to include('R$ 6.000,00')
    end

    it 'shows at_risk projection when on_track is false' do
      expect(html).to include(I18n.t('goals.index.monthly.at_risk_projection', value: 'R$ 3.000,00'))
    end

    it 'shows days_left' do
      expect(html).to include(I18n.t('goals.index.monthly.days_left', count: 15))
    end
  end

  context 'with :wide variant (desktop hero)' do
    let(:html) do
      view_context.render(described_class.new(progress: progress, variant: :wide))
    end

    it 'renders ProgressRing with 220px size' do
      expect(html).to include('width="220" height="220"')
    end
  end

  context 'on_track projection' do
    it 'shows on_track copy when projection meets target' do
      good = progress.merge(projection: 7000, on_track: true)
      html = view_context.render(described_class.new(progress: good))

      expect(html).to include(I18n.t('goals.index.monthly.on_track_projection', value: 'R$ 7.000,00'))
    end
  end
end

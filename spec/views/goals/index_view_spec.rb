require 'rails_helper'

RSpec.describe Goals::IndexView, type: :component do
  let(:user) { create(:user) }
  let(:filters) { { year: 2026, month: 6 } }

  before do
    allow(Current).to receive(:user).and_return(user)
  end

  context 'when user has no goals' do
    let(:progress) { { weekly: nil, monthly: nil, annual: nil, achievements: [] } }
    let(:html) { view_context.render(described_class.new(progress: progress, filters: filters)) }

    it 'renders the empty CTA' do
      expect(html).to include(I18n.t('goals.index.empty.title'))
      expect(html).to include('href="/goals/new"')
    end

    it 'renders bottom nav with goals active' do
      expect(html).to include('href="/goals"')
      expect(html).to include('text-blue-600')
    end
  end

  context 'desktop layout when monthly goal exists' do
    let(:goal) do
      create(:goal, user: user, kind: 'monthly', target_amount: 6000,
                    period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
    end
    let(:progress) do
      {
        weekly: nil,
        monthly: {
          goal: goal, current: 1500, target: 6000, percent: 25,
          projection: 3000, on_track: false, remaining_per_day: 300, days_remaining: 15
        },
        annual: nil,
        achievements: []
      }
    end
    let(:html) { view_context.render(described_class.new(progress: progress, filters: filters)) }

    it 'uses 12-column grid layout for cards' do
      expect(html).to include('grid-cols-12')
    end

    it 'renders the achievements row within the columns grid' do
      expect(html).to include(I18n.t('goals.index.achievements.title'))
    end

    it 'renders the wide 200px ring in the hero area' do
      expect(html).to include('width="200" height="200"')
    end
  end

  context 'when weekly and annual goals exist' do
    let(:weekly_goal) do
      create(:goal, user: user, kind: 'weekly',
                    period_start: Date.new(2026, 6, 8), period_end: Date.new(2026, 6, 14))
    end
    let(:annual_goal) do
      create(:goal, user: user, kind: 'annual',
                    period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))
    end
    let(:progress) do
      {
        weekly: {
          goal: weekly_goal, current: 500, target: 1400, percent: 35,
          days: (Date.new(2026, 6, 8)..Date.new(2026, 6, 14)).map { |day|
            { date: day, value: 100, done: day < Date.new(2026, 6, 10), today: day == Date.new(2026, 6, 10) }
          }
        },
        monthly: nil,
        annual: {
          goal: annual_goal, current: 20_000, target: 80_000, percent: 25,
          projection: 40_000, on_track: false, remaining_per_day: 200, days_remaining: 199
        },
        achievements: []
      }
    end
    let(:html) { view_context.render(described_class.new(progress: progress, filters: filters)) }

    it 'renders weekly label and percentage' do
      expect(html).to include(I18n.t('goals.index.weekly.label'))
      expect(html).to include('35.0%')
    end

    it 'renders the weekly period date range' do
      expect(html).to include('8 a 14 de')
    end

    it 'renders weekly progress amounts side by side' do
      expect(html).to include(I18n.t('goals.index.weekly.progress', value: 'R$ 500,00', target: 'R$ 1.400,00'))
      expect(html).to include(I18n.t('goals.index.weekly.remaining', value: 'R$ 900,00'))
    end

    it 'renders annual bar section' do
      expect(html).to include('width: 25%')
    end
  end
end

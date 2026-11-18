require 'rails_helper'

RSpec.describe Goal, type: :model do
  describe 'validations' do
    subject { build(:goal) }

    it { is_expected.to validate_presence_of(:target_amount) }
    it { is_expected.to validate_presence_of(:period_start) }
    it { is_expected.to validate_presence_of(:period_end) }

    it 'rejects target_amount equal to zero' do
      goal = build(:goal, target_amount: 0)

      goal.valid?

      expect(goal.errors[:target_amount]).to be_present
    end

    it 'rejects negative target_amount' do
      goal = build(:goal, target_amount: -10)

      goal.valid?

      expect(goal.errors[:target_amount]).to be_present
    end

    it 'rejects period_end equal to period_start' do
      goal = build(:goal, period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 1))

      goal.valid?

      expect(goal.errors[:period_end]).to be_present
    end

    it 'rejects period_end before period_start' do
      goal = build(:goal, period_start: Date.new(2026, 6, 10), period_end: Date.new(2026, 6, 1))

      goal.valid?

      expect(goal.errors[:period_end]).to be_present
    end

    it 'accepts period_end after period_start' do
      goal = build(:goal, period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

      expect(goal).to be_valid
    end

    it 'enforces uniqueness on (user_id, kind, period_start)' do
      user = create(:user)
      create(:goal, user: user, kind: 'monthly', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
      duplicate = build(:goal, user: user, kind: 'monthly', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

      duplicate.valid?

      expect(duplicate.errors[:kind]).to be_present
    end
  end

  describe 'enums' do
    it 'defines kind enum with string values' do
      expect(described_class.kinds).to eq('weekly' => 'weekly', 'monthly' => 'monthly', 'annual' => 'annual')
    end

    it 'defines metric enum with string values' do
      expect(described_class.metrics).to eq('profit' => 'profit', 'earnings' => 'earnings')
    end

    it 'exposes prefixed kind predicates' do
      goal = build(:goal, kind: 'monthly')

      expect(goal.kind_monthly?).to be(true)
      expect(goal.kind_weekly?).to be(false)
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }

    describe '.active_at' do
      it 'returns goals whose period covers the given date' do
        active = create(:goal, user: user, kind: 'monthly', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))
        create(:goal, user: user, kind: 'weekly', period_start: Date.new(2026, 5, 1), period_end: Date.new(2026, 5, 7))

        result = described_class.active_at(Date.new(2026, 6, 15))

        expect(result).to contain_exactly(active)
      end
    end

    describe '.for_kind' do
      it 'filters by kind' do
        monthly = create(:goal, user: user, kind: 'monthly')
        create(:goal, user: user, kind: 'weekly',
                      period_start: Date.current.beginning_of_week,
                      period_end: Date.current.end_of_week)

        expect(described_class.for_kind('monthly')).to contain_exactly(monthly)
      end
    end
  end

  describe '#ended?' do
    it 'flags a goal whose period_end is before today' do
      goal = build(:goal, period_end: Date.current - 1)

      expect(goal.ended?).to be(true)
    end

    it 'does not flag a goal ending today' do
      goal = build(:goal, period_end: Date.current)

      expect(goal.ended?).to be(false)
    end
  end

  describe '.new_form_defaults' do
    it 'returns kind monthly, metric profit, and current month range' do
      travel_to Date.new(2026, 6, 15) do
        expect(described_class.new_form_defaults).to eq(
          kind:         'monthly',
          metric:       'profit',
          period_start: Date.new(2026, 6, 1),
          period_end:   Date.new(2026, 6, 30)
        )
      end
    end
  end

  describe 'user association' do
    it 'is invalid without a user' do
      goal = build(:goal, user: nil)

      goal.valid?

      expect(goal.errors[:user]).to be_present
    end
  end

  describe '#next_period' do
    it 'returns the month after a monthly goal' do
      goal = build(:goal, kind: 'monthly', period_start: Date.new(2026, 6, 1), period_end: Date.new(2026, 6, 30))

      expect(goal.next_period).to eq(Date.new(2026, 7, 1)..Date.new(2026, 7, 31))
    end

    it 'returns the monday to sunday week after a weekly goal' do
      goal = build(:goal, kind: 'weekly', period_start: Date.new(2026, 7, 6), period_end: Date.new(2026, 7, 12))

      expect(goal.next_period).to eq(Date.new(2026, 7, 13)..Date.new(2026, 7, 19))
    end

    it 'returns the year after an annual goal' do
      goal = build(:goal, kind: 'annual', period_start: Date.new(2026, 1, 1), period_end: Date.new(2026, 12, 31))

      expect(goal.next_period).to eq(Date.new(2027, 1, 1)..Date.new(2027, 12, 31))
    end
  end

  describe '#celebrate!' do
    it 'stamps the first celebration and reports it' do
      travel_to Time.zone.local(2026, 7, 1, 9, 0)
      goal = create(:goal)

      first_visit = goal.celebrate!

      expect(first_visit).to be(true)
      expect(goal.reload.celebrated_at).to eq(Time.zone.local(2026, 7, 1, 9, 0))
    end

    it 'keeps the first stamp and reports no celebration on a later visit' do
      goal = create(:goal, celebrated_at: Time.zone.local(2026, 7, 1, 9, 0))

      later_visit = goal.celebrate!

      expect(later_visit).to be(false)
      expect(goal.reload.celebrated_at).to eq(Time.zone.local(2026, 7, 1, 9, 0))
    end
  end
end

require 'rails_helper'

RSpec.describe Plans::Subscription do
  describe '#next_charge_on' do
    it 'charges again one month after a monthly subscription started' do
      travel_to Date.new(2026, 3, 20) do
        user = build(:user, :pro, plan_billing: :monthly, plan_since: Time.zone.local(2026, 3, 3))

        expect(described_class.new(user).next_charge_on).to eq(Date.new(2026, 4, 3))
      end
    end

    it 'charges again twelve months after a yearly subscription started' do
      travel_to Date.new(2026, 3, 20) do
        user = build(:user, :pro, plan_billing: :yearly, plan_since: Time.zone.local(2026, 3, 3))

        expect(described_class.new(user).next_charge_on).to eq(Date.new(2027, 3, 3))
      end
    end

    it 'skips the cycles already charged on a long-running monthly subscription' do
      travel_to Date.new(2026, 7, 16) do
        user = build(:user, :pro, plan_billing: :monthly, plan_since: Time.zone.local(2026, 3, 3))

        expect(described_class.new(user).next_charge_on).to eq(Date.new(2026, 8, 3))
      end
    end

    it 'skips the cycles already charged on a long-running yearly subscription' do
      travel_to Date.new(2026, 7, 16) do
        user = build(:user, :pro, plan_billing: :yearly, plan_since: Time.zone.local(2024, 3, 3))

        expect(described_class.new(user).next_charge_on).to eq(Date.new(2027, 3, 3))
      end
    end

    it 'charges on the anniversary day when it falls today' do
      travel_to Date.new(2026, 7, 3) do
        user = build(:user, :pro, plan_billing: :monthly, plan_since: Time.zone.local(2026, 3, 3))

        expect(described_class.new(user).next_charge_on).to eq(Date.new(2026, 7, 3))
      end
    end

    it 'keeps the anniversary day after passing through a shorter month' do
      travel_to Date.new(2026, 3, 15) do
        user = build(:user, :pro, plan_billing: :monthly, plan_since: Time.zone.local(2026, 1, 31))

        expect(described_class.new(user).next_charge_on).to eq(Date.new(2026, 3, 31))
      end
    end
  end

  describe '#price' do
    it 'bills the yearly price on a yearly subscription' do
      user = build(:user, :pro, plan_billing: :yearly)

      expect(described_class.new(user).price).to eq(BigDecimal('143.00'))
    end

    it 'bills the monthly price on a monthly subscription' do
      user = build(:user, :pro, plan_billing: :monthly)

      expect(described_class.new(user).price).to eq(BigDecimal('14.90'))
    end
  end

  describe '#billing' do
    it 'exposes the billing period' do
      user = build(:user, :pro, plan_billing: :monthly)

      expect(described_class.new(user).billing).to eq('monthly')
    end
  end

  describe '#features' do
    it 'lists the active pro benefits' do
      user = build(:user, :pro)

      expect(described_class.new(user).features).to eq(%i[exports insights goals history caju backup])
    end
  end
end

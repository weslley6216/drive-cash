require 'rails_helper'

RSpec.describe Ai::Readers::LastFullTank do
  describe '#call' do
    it 'returns the most recent full tank refueling' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 6, 1))
      last = create(:refueling, vehicle: vehicle, full_tank: true, date: Date.new(2026, 6, 15))

      result = described_class.new({}, user: user).call

      expect(result).to eq(last)
    end

    it 'returns nil when user has no vehicle' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result).to be_nil
    end

    it 'returns nil when no full tank refuelings' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      create(:refueling, vehicle: vehicle, full_tank: false)

      result = described_class.new({}, user: user).call

      expect(result).to be_nil
    end
  end
end

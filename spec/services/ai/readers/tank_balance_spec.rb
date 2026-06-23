require 'rails_helper'

RSpec.describe Ai::Readers::TankBalance do
  describe '#call' do
    it 'returns balance data when vehicle and refuelings exist' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      create(:refueling, vehicle: vehicle, total_amount: 100, full_tank: true, date: Date.new(2026, 6, 1))
      create(:expense, user: user, category: 'fuel', amount: 30, date: Date.new(2026, 6, 10), paid: true)

      result = described_class.new({}, user: user).call

      expect(result).to have_key(:balance)
    end

    it 'returns empty payload when user has no vehicle' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result[:balance]).to eq(0)
    end
  end
end

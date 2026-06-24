require 'rails_helper'

RSpec.describe Ai::Readers::LastMaintenance do
  describe '#call' do
    it 'returns last maintenance for the given category' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      maintenance = create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 50_000)

      result = described_class.new({ 'category' => 'oil_change' }, user: user).call

      expect(result).to eq(maintenance)
    end

    it 'returns last maintenance across categories when category is nil' do
      user = create(:user)
      vehicle = create(:vehicle, user: user)
      create(:maintenance, vehicle: vehicle, category: 'oil_change', last_done_km: 45_000)
      last = create(:maintenance, vehicle: vehicle, category: 'oil_filter', last_done_km: 50_000)

      result = described_class.new({}, user: user).call

      expect(result).to eq(last)
    end

    it 'returns nil when user has no vehicle' do
      user = create(:user)

      result = described_class.new({ 'category' => 'oil_change' }, user: user).call

      expect(result).to be_nil
    end
  end
end

require 'rails_helper'

RSpec.describe Ai::Readers::MaintenanceStatus do
  describe '#call' do
    it 'returns maintenance data with vehicle' do
      user = create(:user)
      create(:vehicle, user: user)

      result = described_class.new({}, user: user).call

      expect(result).to have_key(:maintenances)
    end

    it 'returns empty payload when user has no vehicle' do
      user = create(:user)

      result = described_class.new({}, user: user).call

      expect(result[:vehicle]).to be_nil
    end
  end
end
